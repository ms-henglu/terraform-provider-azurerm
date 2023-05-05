
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505045848595257"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230505045848595257"
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
  name                = "acctestpip-230505045848595257"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230505045848595257"
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
  name                            = "acctestVM-230505045848595257"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9871!"
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
  name                         = "acctest-akcc-230505045848595257"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApNRIOOySidi32f98yimn+igwoLT6cg4pDGIYsRH7qQIclNOfxdZx9LaPCHu74Dj+5svTn18d2W2+8BfDOpC6C+zp1Tdl6AVzj1Y5NwMw2C1G/8c02H8RBwAkauDeKFBpd8/xVcQCDB3vnfuy9JaQ7jgKS2254hvWN0JVD4js+Hv9qphw5upCWxBF92/ywnslywuMeY8TZMMj+bEGBap5D4O+92EdOu7WLdStr8LMzJn76DJCWABHhYfWWXuPQsLfdrSIt98PtKFkgxm8m8MFFbZtMuPXLBdDM3RBHi/CL6zTyEbE95m/5dxZvk73TBhVGoqZv7cVzQgbDQI81pWyjOZAooa4dPi/7Sf1UMueUVphvfwGt/h1VLz/TfA/Ijn0tEH0Zi6WWjEaItQGEENic4PCSNsY+K4zwKWunpgtelg5WRJvt8QpDOtzZLIo0hcDy36S1iUrKXSdLAxVku74zcpNooCcCXNVRHefOXXAZKoJQN0YqpQHsSVOAvPRW5YQ/gqJ5svryCuxZbT6y8f5HgDEJUmEr1GvO0YA0pwWBQJ+rii0y3cqG87BzUWnikMr0lmHTyLkBiQ8B0JiyPW1OcTnIfIHCqfUqXpi2L0XLp1c5nw3vEW9Go+O89zHyvU6Pp5tvOCPeMI0qRtwJyiUjkISm2KP1zBgiW9wYh1SGFsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9871!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230505045848595257"
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
