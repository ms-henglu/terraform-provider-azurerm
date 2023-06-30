
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032653574952"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032653574952"
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
  name                = "acctestpip-230630032653574952"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032653574952"
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
  name                            = "acctestVM-230630032653574952"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6133!"
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
  name                         = "acctest-akcc-230630032653574952"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5KGhkV+itn/Xq4pa9dsmMV2e/sylWvUgLAuMihKtDmE/F/5sDm+FRdbE1llkTbOcdbQSwCiAlJffSCCqVmJNqWz2YOXBbFSW/MnAcu0H5CnSxdXmXS3j4S6QAss06RMrMT3sj1rsMpTJmFDdYfbE4pDbwPaxXTZlTGBZWWkgh3ZwL4kiKsnCv6bc/3qEYHFPOSZdf7qfmkS6y5NPbspnm8scMxP3AZG3evvEbWNgi5rKOyCO21RXOEqJl3gvSlp1mGR/Sqc/yYAJKCl0D1gWS5HR27lwwOOetwNcEiRzzSBBK1lbjDnUsBjzQPzAdgvFPeXv738yzHSk7vrd7O4FrkmfLIwQ0Hdul7I2qEKQwL0pEgUJYOdS50j8mP4udhk2NQzyb0AjdpHNDqWmnkQw2/94ZYjum8YC8HksyC7lhfn/qa51x12EpbTLI0JvggEAVlvjJWDTGexwdkzVe4iw/iQYdGrfC9KeNVpgcfTngKivC4HdPch/S3bmOKXgo7RM14uG8wzzx9ub5WLrdRyAOaf00gKx0nhJKH6TR+xEOPa5PxL+M0ssHLzpZeww5S7vtVm6g+e+ohzlLpKlFWgSt3z1xL00Gl307Warna+QRSTElQnkGSKLQ/7uaA53mXqBzRSALlJHqKKRjqA2D0beIMkXM4dfvSlIhFuS3TTeB/kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6133!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032653574952"
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
