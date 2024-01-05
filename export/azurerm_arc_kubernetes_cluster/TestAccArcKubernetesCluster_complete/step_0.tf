
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060238009809"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060238009809"
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
  name                = "acctestpip-240105060238009809"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060238009809"
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
  name                            = "acctestVM-240105060238009809"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7261!"
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-240105060238009809"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAlm1dxG9WBBPJvGltJujWCP6JU+SHSNfc3M/kN6wvQOyGJjfSW+GORUQ623wYFp6yXRsx1MCdHneRolEb92kGizaGox/iRg9/HOW/Nr49pdoQpiZo1GfFeV+vWUslIqvGZTW0IDo4boUGETIx0gkRwmtkp6BcmUvmC2tnHrT21MGV3lwiWK0RJfOj6sD0eOroFH29YkFmiNknQGXihuqf0dyYR6hXhVtUMb7c0jxQRH/yREbUWpQVP88KXktwxTCet8K58sLfEPxSHm+KLMkBXTa9K5OgKHYUiPQbM3w99J8GTvnawZ+85DNIjQxYnWoan18sl6gEO16wwdGhGrk5tHdzXPxDnvNMYHv6t3Ir8OknepL/iGs/S+E7/YyYfOTyi40N1XWKdcBJ+pdPmNkQhb6dVKlN9G0yInsjO6Vb/fTx04036dHOTBVvJeK7vr/wOzWlr6Nlvz0HTMIRRYyPAQPgi0p1BHMQ8XXrWIDhh2BXE7vPnM8VVt5QRiwFCSrmVAd7bWHpiFmQ1KCAM5GuGGJ7wcHCj1qN3eB6YN+bv1Bh7pVsXJarUPdXCrW7fkFGd26HydcxCdhRSJ86TJpxFjavIDAps8OJlWIw84P3gkVtTwxjjFhYcJvXrjZzNBOCTNZsc16EpJOz7n0hddlfuPpXSJLRvkRJ429lpP0qyMMCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7261!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060238009809"
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
