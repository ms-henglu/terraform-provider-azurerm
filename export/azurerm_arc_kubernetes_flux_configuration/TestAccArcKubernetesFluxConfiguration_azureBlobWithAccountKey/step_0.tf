
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040551022774"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040551022774"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-231020040551022774"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040551022774"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-231020040551022774"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1704!"
  provision_vm_agent              = false
  allow_extension_operations      = false
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
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-231020040551022774"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5CXQi4BiYA+e0i5W1uwfcXVtJ6ZNR57AjzzMDeTUwVFUkdjsp2TXpDnB2QzJq/eAB9WDjB/zVyXHCIpSu2AB0/E1vqoJi+/87fdbIsOvH5A/E23assH6hfw9Ejv33mcUvK/ysbqYAJLXmkUXocWCr+Hna2X/v7b0ypDkatOfC61hAXiJSmUi1HA6T/BCSnop8UeNaoskx/Znf/ULAiOHaNPUMKi1g/zd20ewsC7+5RIT+0z6bJx39dmZTCgXDO1Axo4RvGMr9ijBsjF2pwUPDUe1sigBgiFaDVZNunSK1/NIZLmW3tebsDRZrXqHWw9Lyi3TE8ehcNu5lvOMIf2LbU89P3A2U5qidv17hUJgqRZadL0MW1OgrrT51lk2SBKmgrkTMuLMuUyBVY0VqDPTZ8q0aQ53Uj/iaFNDfbBJcOBfi9jQuD4ol8Y/lTDHuoTzN1e3XErDS5MQwwyipeOxbREMiDQbRHNf+PPN1SBP7FdWQ0TdhTG908qFmdwHfRNNqN/BIH8AISYBAnBYBv1hL1XEtOSkUeTzXLfvi5P7vCU6hFHaewWa+RntI3mDdQRi2HsBHLF7nmSs1nxJQKOcMkjSbJXbLAvVC+dWesKfLc0OCf3KaevUqKCJTr1pHsL0LVj5hbi430D8ud6AzUocHwm7ah+zN2y6eccAkJ3ZYCcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1704!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040551022774"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-231020040551022774"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa231020040551022774"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231020040551022774"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231020040551022774"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
