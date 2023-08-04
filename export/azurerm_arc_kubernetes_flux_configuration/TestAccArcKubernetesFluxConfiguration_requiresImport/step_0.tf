
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025441952267"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025441952267"
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
  name                = "acctestpip-230804025441952267"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025441952267"
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
  name                            = "acctestVM-230804025441952267"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9336!"
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
  name                         = "acctest-akcc-230804025441952267"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvAMOJ12VSUWqJOzsf/ZPlfqPAhl/m0d/54cXv4tj9k+gZAs26+rjquNRCccp7go7W3gmP1fCXR+jQIpcdubA7gqSvjVsedhCumfo/tELAQ+85sV8gCLZ/njvKhsmCppZ2yAH3W0K+/aMEtZBq2h/sqD0hZckegdf1kae924spRZFXDXCtU8acP64D8C/3vKRX7/vkebkdfeq1gQWsrMZ7qp6jkI2fr8HqbgqxPMpdkzytf/tEmjHMO73SmCRnkDQLVkNdF/g+kbOAKFkyTiGpJX73yQ3QhP/jztLOktNcXnQlcHCCdaeojQUN+R2tzyZEh9YkYCHnw1fpiyuvLuio77VI7zTfClcHVG1Um/aTS+cK42HWgMNf0uVorsQNw8qO7cSwMGXc57pNi7x3CvxM9dErKkXrr2K6LMsi1quCSsZUWhvrYv+VuzGsobmOWWe/3ysRBQ1UnvVJ+vtvBgMKE4Mxt60vR2a1fRaNh1ngw6rcUXCFgSjydzUWpMf820v0giFVfLlxMc/iQysHwfd/m+/TgPFfApRO+nViiLrMR0/3L6QxKyS//vteL/+cvatlecs22vAgZMgcnwT02G/lpx7tRc/HjpkhO7z8OF0x5w5qwWcBycri7hYc0zvViMfqHDFPDl0iJrlhELXOoosMk4+NuoEYRJNI5ZwsIFwhNUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9336!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025441952267"
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
  name           = "acctest-kce-230804025441952267"
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
  name       = "acctest-fc-230804025441952267"
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

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
