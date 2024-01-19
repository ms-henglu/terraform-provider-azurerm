
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024503642268"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024503642268"
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
  name                = "acctestpip-240119024503642268"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024503642268"
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
  name                            = "acctestVM-240119024503642268"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7395!"
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
  name                         = "acctest-akcc-240119024503642268"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA11lOF8+X7vVvKEeB0bFTF8kbyqzYOLb17UzUr3i/TneZDNn4abNHGHf1KJsJziPB6q4XcVGDf0vFPiT7nOO4ydAgp6/cz5f19L6EJ05EEWKycgnv3ETWDavMU4KGwnS6s0HblgIe0n59RbX5gql0HioHLYy/g0MfvnLFhlWlvyyETILN/c8WdgARl+bY8Xp6sBBC+0SbbOkYgLx1yZ1yHtCL7NRkYiqs79EZ85WQKOVJ1lt0kcokCdZaPNHdAwEqts/4EDvP2Ns0OmRbMYONpIQcAV7op+0uh5IrgOOvbn0Ajs2qfa2wmTC+zF0OSW2Y25esg35a7vZPtQcXmM9pZjDpez1QbFOuTr5KpDosTxnjVQroSiAU1PMTf4ySdaS0jHT/XJTTfFPM3ccvmhJN+crfjCC9Nt4CEOD9+/9MgWW4nNXj0wGi/WjrQ3Dl/hPFmNep9ztgjSLzefPE0Z6f6vLcH4VoT3rFQHN9vtM5usWY76wovEJClJR9dzgvZLajLYsXGPz/e/MGTVbwqp1t12Xc5zkoWZyJg84AU+nFtxic1uSlpBI6Oq/pPnBwzPir8RkWMaJejko7828+9PojRBdvEmAmReermgx4HVx2TcBo222xqZPfcrFswf146yZ46y0qcxku2pTpf4sih2yOKVefPqn4ZUhNbSxdDM3FxrsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7395!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024503642268"
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
  name           = "acctest-kce-240119024503642268"
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
  name       = "acctest-fc-240119024503642268"
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
