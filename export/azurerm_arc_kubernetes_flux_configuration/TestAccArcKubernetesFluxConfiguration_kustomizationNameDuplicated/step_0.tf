
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063319075992"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063319075992"
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
  name                = "acctestpip-240105063319075992"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063319075992"
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
  name                            = "acctestVM-240105063319075992"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3468!"
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
  name                         = "acctest-akcc-240105063319075992"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2aFoxo8z/8EBqFvK++PVQRMc/61lxsIyri8hTQThye1CIneMGd6te5emSPhFhj3Uax41GJFBsma5mxIB7qC1qjHaPN4Y6KYI4BXkN8bYxjCY1NHE0wFBuU+ORnOd4nZ4x0otSjW6/tlBOKeigQywjhgPJyZxRrS9oc/7xXCnaZO3RaGAoN/MNl/UygCFtcaD0WVeWn+/iQImrvzozdPg6+tPHiY/SEHLAY/Qbe3kprHH+OLl09/uSVrNtD2g85rzVTGyO7iv+UVhRPOPHTCHvApmvasfrHIv6PAl6RnexuMnRgqguEvzunKO3ZkAqGgljQGhcG7FRTZwkDXoHlVFX1p08RLcnp07+zp+UAla7epj6n+FnBJ/B3arG0QJ2DoIH0LAb98dl0hsxSGe/hJnvlBcRxzyMyqJmltL75apI3ThOYkn2jmOapxqX+b4Rqe2jGXySL90JibxdM711kAqXoBK8OGS5T8miPoFqEDDOZfZPbgtgLasdyJ9fWmBD01hpGPImCOUKzm7d4SLEsrXlQYpGJ7uY45ceZBP6ZHy9gLMsp0rlPxNbrMbSTSGJ9f07IC+VqRVDrYU87EB/828GF2z4f/qYfq8772/V18WnXp17EiyBvMTnfFS5ENwBmltTFoJzShIYlHhmYwLxCXTHzfJLcX9hNEo5AH/ZyVAODMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3468!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063319075992"
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
  name           = "acctest-kce-240105063319075992"
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
  name       = "acctest-fc-240105063319075992"
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
