
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033835928636"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033835928636"
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
  name                = "acctestpip-240112033835928636"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033835928636"
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
  name                            = "acctestVM-240112033835928636"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5500!"
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
  name                         = "acctest-akcc-240112033835928636"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAv54rGgfWDP0NdV5ekYTJei6tIBU2R1IWENAjN1S5GvpizxdD1c7R9aYMiv02edNUJUFtoo3ohLxWqtFLjnxZHI88mg2FLrr9JW7pC9eYgFmYgJ8UuWFz6Y37TaKWgSgdixI1nUcV4ikt6GYd0fzNfYhJGlrTzwGuzuP/B+1bvvLq0cvzgTd9lstM9neXrMdy+4p7+8LV1Il56hWwG91DLm1qWFS/voumgoT7URgAQlEWGRNIR/7A5Du/rI2ov040q2dn9pDPq9gfOKU4soNFElgTKTFVGYQ3zkIe8AeOIgWoAHe4tTLJez1Z+J1FM/mGBVX2SCYgsxmhS9frVGu9YJvH71PeVKU5wm26/BDc8TtYBKPWy+uUU0qy9WAf1kFnqXmsBjbq3awlsE0m546TKNUnqMCa01YFHm/q5GIiwrIBy2ecqFyA3pDv0qy12lkz/uK2dx7Or18xIZwmb2U/MJrPIgFI+TMKWmL3uK/LpVEHUuCXCqQW5ILaP4N4cNa2qLjzu6a8/ga5yz3/fH8hpA7STtK+lowdVUNoYYlwpw9f43dUytKAl5POlaQ/cMZfaARID8mTk65tAS3SnuSlHdtB3EQARIIp7BUKlOyMyAKkz6H0OqoBnPJD+xuseTkxhchATuUyXCkeQH93QlfcVXHd+NqC9C6Jm3itEopWCNUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5500!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033835928636"
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
  name           = "acctest-kce-240112033835928636"
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
  name       = "acctest-fc-240112033835928636"
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


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

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
