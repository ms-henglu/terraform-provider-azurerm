
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071339874983"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071339874983"
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
  name                = "acctestpip-230613071339874983"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071339874983"
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
  name                            = "acctestVM-230613071339874983"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5598!"
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
  name                         = "acctest-akcc-230613071339874983"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAu5+JxyOz0idJ3bsC78YBkaLU8WkzyWHPvd14WrDx4COLMGlw/uOG/PnSbqiO2HL1h1mLF1+vw0xukM+Ue42ZBX1gp6yQS1jekwOr70zTgaxGPXuR3XHdfuqO2+MHsijj3+E8lRX+jMveJEB7j8lIjOTD4Pnrn1Kpq5KuRAdtOmFLFIeC5lfgk82d5NTCxKl+3R8o1ZqvbI303YJgZlKtx5ejcwMJQJzcbowPecc3lXPBIQJBfDDFvrJreFjOG9soueqrBr/rvam3O2Fb4G33ZyIZkDfy/RPufbB41oxouyNhsuUfftjgp87+lzWTOKfdXkMxTRl6N1FhEutAghbiNA6SqHhcFlEb87Q3PmHOMDYQs/rSctbL/k391pIyATgVacvw8CqLZ6J1ANUewquecaZdtaDXEjMyN+CAIM9njQbcws5RwePQVc9Aqgs1tFR9XbG+NriIf3uVEgkwQ6/4SXF5WjTK2vPcsxh5bDh+TP9fuu5QmSQlEzJvWPb6EwdkqeKYqwDO/Z2Bbj0bOWrnq24HRf221ZIyvOw5sKIpoCr59aZCrVl5m8ZndcIxamUrOmnJOBXBABp+4R0LRxkBXtNTg+Ts7D2aRzCI0jbPvDHXnIRvvw2H2y/gaK+X/mQdKF5heXMAhstyEhQLt/CyNdNzxTzMmwbvQ8qrtfeH4B8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5598!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071339874983"
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
  name           = "acctest-kce-230613071339874983"
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
  name       = "acctest-fc-230613071339874983"
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
