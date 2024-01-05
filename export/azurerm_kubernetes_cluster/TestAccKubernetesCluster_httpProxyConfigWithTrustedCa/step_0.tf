
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063536343327"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240105063536343327"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet240105063536343327"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_public_ip" "test_proxy" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "test_aks" {
  name                = "acceptanceTestPublicIp2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "AllowProxyAccessOn8888"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8888"
    source_address_prefix      = "${azurerm_public_ip.test_aks.ip_address}/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "test" {
  name                = "test-nic240105063536343327"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test_proxy.id
  }
}

resource "azurerm_network_interface_security_group_association" "test" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

locals {
  custom_data = <<CUSTOM_DATA
  #!/bin/sh
  echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
  sudo apt-get update
  sudo apt-get install tinyproxy -y
  sudo echo "Allow ${azurerm_public_ip.test_aks.ip_address}/32" >> /etc/tinyproxy/tinyproxy.conf
  systemctl restart tinyproxy
  CUSTOM_DATA
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "vm-test-proxy240105063536343327"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssW0RD1234"
  custom_data                     = base64encode(local.custom_data)
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240105063536343327"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240105063536343327"
  kubernetes_version  = "1.26.6"

  linux_profile {
    admin_username = "acctestuser240105063536343327"
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqaZoyiz1qbdOQ8xEf6uEu1cCwYowo5FHtsBhqLoDnnp7KUTEBN+L2NxRIfQ781rxV6Iq5jSav6b2Q8z5KiseOlvKA/RF2wqU0UPYqQviQhLmW6THTpmrv/YkUCuzxDpsH7DUDhZcwySLKVVe0Qm3+5N2Ta6UYH3lsDf9R9wTP2K/+vAnflKebuypNlmocIvakFWoZda18FOmsOoIVXQ8HWFNCuw9ZCunMSN62QGamCe3dL5cXlkgHYv7ekJE15IA9aOJcM7e90oeTqo+7HTcWfdu0qQqPWY5ujyMw/llas8tsXY85LFqRnr3gJ02bAscjc477+X+j/gkpFoN1QEmt terraform@demo.tld"
    }
  }

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.test_aks.id]
    }
  }

  http_proxy_config {
    http_proxy  = "http://${azurerm_public_ip.test_proxy.ip_address}:8888/"
    https_proxy = "http://${azurerm_public_ip.test_proxy.ip_address}:8888/"
    no_proxy = [
      "localhost",
      "127.0.0.1",
      "mcr.microsoft.com"
    ]
    trusted_ca = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJ6RENDQVMyZ0F3SUJBZ0lCQVRBS0JnZ3Foa2pPUFFRREJEQVFNUTR3REFZRFZRUUtFd1ZGVGtOUFRUQWUKRncwd09URXhNVEF5TXpBd01EQmFGdzB4TURBMU1Ea3lNekF3TURCYU1CQXhEakFNQmdOVkJBb1RCVVZPUTA5TgpNSUdiTUJBR0J5cUdTTTQ5QWdFR0JTdUJCQUFqQTRHR0FBUUJBcUN1Um94NU4zTVRVOHdUdUllSUJYRjdpTW5oCm50cW1HVktRMGhmUUZEUUd2K0x5ZHVvN0pQcUZwL1kyamxYU2ROckFkejVXeGJyWStrRHhJcGtCUXRJQWtJREQKWlZtVHVlcTNaREFmY0dkRU5uek5KVkNhUGxIWEpMdkVFSU5jb0prVU8rK2NWeXl3ZHJlVkpjNjd2aE54MVRkWApWM3BwN2YrUmJPbU5LYm5WUkJ5ak5UQXpNQTRHQTFVZER3RUIvd1FFQXdJSGdEQVRCZ05WSFNVRUREQUtCZ2dyCkJnRUZCUWNEQVRBTUJnTlZIUk1CQWY4RUFqQUFNQW9HQ0NxR1NNNDlCQU1FQTRHTUFEQ0JpQUpDQWJiYjdzdkkKNXR1aEN5QTNqUVRTZ0E4enB2azBZV05Ya1owN3h6ZFY4amRNTXVtQ2FXOXljRUlxSjVLU3F1dVBoVXc5b2VregpCNTFkYXliVjFWUVhWVmRWQWtJQStrTU1TSnp3dHpIcU5BVVRtaVpQY2c3SDh2MUFTbDR0UjZscEtUcFVQWTJYCmxYT0N0MllmNGRzRnNpanV2emJKQmR4NzVkNEVmNVRSSFBjZytQSE5aZ2c9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
  }

  lifecycle {
    ignore_changes = [
      http_proxy_config.0.no_proxy
    ]
  }
}

