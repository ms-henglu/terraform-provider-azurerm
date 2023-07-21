

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011132348133"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011132348133"
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
  name                = "acctestpip-230721011132348133"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011132348133"
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
  name                            = "acctestVM-230721011132348133"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7516!"
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
  name                         = "acctest-akcc-230721011132348133"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1pGHE1ZmemOzuSthFiUfFQy3LGBUPEFev+8f0QBLtgtIwFYCUnqVHH0RA98dhFllGzm+ExoI/l+mEq3jh2bwi2IrnA77ifOslJf3pA5MswkQBZwkBFiSOlCmQOoumF5LvLkDeFkp1zP51oQAJEsuqnwyiHB+YDG9j0iGEhRMoycxJ45+YEGs7Dr/eWwxr9mJaLv5haAC2a1DIddMDkcifO3UpiHS3XoRQc9vPwEaQlGryF5ykxVBMC0+/ET+SGXIR1oxjzjHcn5CmmXpay5PxFBTab5sut9dm9nsGZ186K3b6b1+wFLlpFZuz2SCszaSkJRPeoe21h03qWr4nNfRMHdexfsRnanBnIqB3DPUsOdfoPlFkx2C+AIIs8TfzaKtivHY5ykGw4oc5NAp0KhaPRENdfy4V0/PzooCLtfIFYxKUHRZQtMIMe8BbvwMSjvCBI2t2bGy0PN24MF575evLdhMnm5OhhvS84B/mJeIOzFfArtSeBtf5IrJnxTeQ14ozuopBYtJLfgbrs96vWnx229z9NL+PnK4phu7I2S0ocJfI75Ik5GslC11b3zIAEq5dFV8tYYCxKPObQUs8QWik9i3xs8gPYoFia9e75Tz3IVyS/oR34vBfsCedF75O1j7XQl7wSmYhKBL0i99U2ik8QYCWtoc+rjdQ8DcjFg1FGsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7516!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011132348133"
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
  name           = "acctest-kce-230721011132348133"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
