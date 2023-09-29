

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064333346554"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064333346554"
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
  name                = "acctestpip-230929064333346554"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064333346554"
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
  name                            = "acctestVM-230929064333346554"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5001!"
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
  name                         = "acctest-akcc-230929064333346554"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAy6a/Ip2gtN4wXV5a27hSP3rY0A1LvNXJDkNYWKh6d6X+PCVpaYx6qA/r8+3hunKHEDFCu910Y03r7SKA/B2y0Dt+ucFoO76P5SpKpwKzCklyq5boOsAhfcCYfQe8AoDyn2nU3v+h5+RUgBxy4UV9NfLBSGXsl+sYMqM58NT1XmeyPhOvTEXpCw9MYaPnWbKKv5kt6E/yjZMhpMRYdtmdRSR/Sj+BEpX82X6gC8itMWkoQw0ZRQJA5tnyP8msOLXxLFc3Qqu62UQI4S1wgnGE4Le61GYaA2lr2HgfI6so1APZjkLPKOB5t+0iVjBe2JZ24pfeQsJliKtk66d5W3z0RxY4KguTCwPn2RyBehH3l1RG8ABrIJLFzjb5a9KDqUp0Jhj3j2mLNTBZJRl72CZU+rMjhtGJljROwRrIW+QDXyLc2jiF0757nuFjFfTlp8qG/0Qocc8/ILQuFPwFD52ZQJwq+xXx6q/l1ecdrCJH5c15wmhhMhoIr6nro67DTo2bUd6QFpCMxgGA6T5iNr1F7IrzpUbgc9H6iXUJnwVrLSBIBoWWt5ecIQ/R4xx8hN9SyAoe50atTtlX1kNvxUBNVoXw4r/U2MWgNV9sZANuav0g3Fy0nDMLV4Zu6v0Y9S2csgnhayt3zab9mFp5C6KnJR9BDiT3+GT/ZvMFWUG1X7ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5001!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064333346554"
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
  name           = "acctest-kce-230929064333346554"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
