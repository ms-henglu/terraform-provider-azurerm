
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024524439709"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024524439709"
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
  name                = "acctestpip-240119024524439709"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024524439709"
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
  name                            = "acctestVM-240119024524439709"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9420!"
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
  name                         = "acctest-akcc-240119024524439709"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuJN6PKlwQGmEcUs+ibloQs/pdFpPOh09v1yBjYsdNXkuPybnhgI7fSpSk5NF6x20c05/6OhAhlRzslgoGLaUBRfgbuF1tomvsPKM6Lv57bQHKgVQpJ2xumHZuhwlX7Flp7VaSnLK/JZ+iRygBw22b6PYTQWHqYDj08AsdIVJWC5EWNWjAL/2PqXZgfj13gu05n5IlStfHxt5/S6QABbDipsGMWBa8zySkFx3aVc1BUBaoUMJep7G0GAM2BBkk6T47BwHaY/a4QK0EYawHxgsdmPvjSMKeFiItDsEWsb+9e+uddV4Uqw0BsrV0Cx+8I8cDxd9odydoM65LAaAJQVbaf3IgpUVxCVC1MDCa1yttxqmK16eKbtIdjJsiDGXHWc+b+9o8Ck4ue6ycI1SV0QeoG1mnCqmN/EqGg6vbuIKphX4bJ+Z6JEtbMthSUY5Y4whkf0tRUsi6T7d7b+8a5Erz/cK7SSZyz1u7aavtg/N1SlH8S656DodYHM11Y7y0a/1/aDIJO/3doMA1qhhZ+2JxsgSIzX7cn76gzgaJD+Jm3lrvX/RBpJ58TclnCJeZb+tZtuxglXJjogfnoCAxNzp1l8O09SsgSDFuettzD+L5H4B4ITYr//PK6P4RYUn+tj2lf+rPUbtGebXUZoDbppJGNEeBLSpPG4E6pAU9T8TIEsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9420!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024524439709"
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
  name           = "acctest-kce-240119024524439709"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240119024524439709"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
