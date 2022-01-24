
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124121906338464"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet220124121906338464"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet220124121906338464"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.1.0.0/24"
}

resource "azurerm_network_interface" "test" {
  name                = "test-nic220124121906338464"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "vm-test-proxy220124121906338464"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssW0RD1234"
  custom_data                     = base64encode("#!/bin/bash\nsudo apt-get update\nsudo apt-get install tinyproxy -y\nsudo echo \"Allow 10.0.0.0/8\" \u003e\u003e /etc/tinyproxy/tinyproxy.conf\nsystemctl restart tinyproxy")
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
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks220124121906338464"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks220124121906338464"
  kubernetes_version  = "1.21.2"

  linux_profile {
    admin_username = "acctestuser220124121906338464"
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
    network_plugin = "azure"
  }

  http_proxy_config {
    http_proxy  = "http://${azurerm_network_interface.test.private_ip_address}:8888/"
    https_proxy = "http://${azurerm_network_interface.test.private_ip_address}:8888/"
    no_proxy = [
      "localhost",
      "127.0.0.1"
    ]
    trusted_ca = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJ6RENDQVMyZ0F3SUJBZ0lCQVRBS0JnZ3Foa2pPUFFRREJEQVFNUTR3REFZRFZRUUtFd1ZGVGtOUFRUQWUKRncwd09URXhNVEF5TXpBd01EQmFGdzB4TURBMU1Ea3lNekF3TURCYU1CQXhEakFNQmdOVkJBb1RCVVZPUTA5TgpNSUdiTUJBR0J5cUdTTTQ5QWdFR0JTdUJCQUFqQTRHR0FBUUJBcUN1Um94NU4zTVRVOHdUdUllSUJYRjdpTW5oCm50cW1HVktRMGhmUUZEUUd2K0x5ZHVvN0pQcUZwL1kyamxYU2ROckFkejVXeGJyWStrRHhJcGtCUXRJQWtJREQKWlZtVHVlcTNaREFmY0dkRU5uek5KVkNhUGxIWEpMdkVFSU5jb0prVU8rK2NWeXl3ZHJlVkpjNjd2aE54MVRkWApWM3BwN2YrUmJPbU5LYm5WUkJ5ak5UQXpNQTRHQTFVZER3RUIvd1FFQXdJSGdEQVRCZ05WSFNVRUREQUtCZ2dyCkJnRUZCUWNEQVRBTUJnTlZIUk1CQWY4RUFqQUFNQW9HQ0NxR1NNNDlCQU1FQTRHTUFEQ0JpQUpDQWJiYjdzdkkKNXR1aEN5QTNqUVRTZ0E4enB2azBZV05Ya1owN3h6ZFY4amRNTXVtQ2FXOXljRUlxSjVLU3F1dVBoVXc5b2VregpCNTFkYXliVjFWUVhWVmRWQWtJQStrTU1TSnp3dHpIcU5BVVRtaVpQY2c3SDh2MUFTbDR0UjZscEtUcFVQWTJYCmxYT0N0MllmNGRzRnNpanV2emJKQmR4NzVkNEVmNVRSSFBjZytQSE5aZ2c9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
  }

  lifecycle {
    ignore_changes = [
      http_proxy_config.0.no_proxy
    ]
  }
}

