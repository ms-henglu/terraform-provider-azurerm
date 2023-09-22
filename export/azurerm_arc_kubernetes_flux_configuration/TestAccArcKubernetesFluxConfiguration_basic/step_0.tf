
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060600250000"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060600250000"
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
  name                = "acctestpip-230922060600250000"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060600250000"
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
  name                            = "acctestVM-230922060600250000"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2889!"
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
  name                         = "acctest-akcc-230922060600250000"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvQv31YUY3qQfpyteE4qGzu445z56eJmg+phmO8K29LDovo/3idoGGB0leYxnp63vhwGK/RVGejFstNFc6KnfsY+YJI7Ol06Dox28zaityKRhyCzQAtGJ6eec+ukGMn/nFyv5KRgc2Me1Hpy6cWXA4JXXhO/pezJh8j+Pz3sL0dVyF+3eKwOf14lurmtDdkxhrdKRojo9B9fbTX6tZDC4FLwm8meCjp+TZR94syE7KO/PryZ+4heB0xR4BKu3Ix44oZaZVX12so8P23wmedFb0kv3jxOZNoYvIaF5sDe3b572ekqIj9kXbmsOD9u5P4GSMm28OrD04dpLy8tHkXtyGvAuPHjfdus92PdLZRWrNdkpu7tvc6eEP3KIq62gdE1DalmazPU5DQnfmGP02VCYBrVPJdzm/SyFa1J5E2vQubOGiCPiITJIJkOBF4ljS3Jsn3MFz6Z2hhCHTm8PAxLP57DxOwtdv1jlhZETS+21V0p8corzN0LQBxt3dRx/0FwA7rB7LZSVJgXvIkpZ45ojnsTYuVE6mBjesG7qU+xN3tm0JB/ogMosmka1oxOOTU4YaYCjd7x7R/e/zNf7/ziUtGx64+SpYMAQWSMGDMXTqcOiPg41GXc1aBPEdukxZd2fQXubchMxozW+a7pxqyS2GnJ3sCIGTwGHYZnT5yN87GUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2889!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060600250000"
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
  name           = "acctest-kce-230922060600250000"
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
  name       = "acctest-fc-230922060600250000"
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
