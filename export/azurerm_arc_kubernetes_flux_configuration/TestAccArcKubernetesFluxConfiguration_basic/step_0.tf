
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024039768539"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024039768539"
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
  name                = "acctestpip-230825024039768539"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024039768539"
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
  name                            = "acctestVM-230825024039768539"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd119!"
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
  name                         = "acctest-akcc-230825024039768539"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3pAKgemDvuW+4tkjtQRn7ybr3Fmn67MqqNh3RTGSINivxiv2o/m814XvqHdQaor+nzJ3+90YDUJ26PtWIO6vGPpbFZTITBjTZItEegDmNIGmC77HvygH+mmib2zNZs+52uQAUGrkJJAyiilDb0cxGHzUrgSecB0hLUWUVmgrJMLKTeuss2N+prhCFQNTV5debyIC6EbGBoadfCYLsaXfD1Shq8PNyNbvATE/WJV6OuoUhzCk/jcV5/wBaDtMzwu+IeGJQxIbaDfjdVhDbOHbM223o4/okZDXU9vbGoANw7R03u70mNLebmeWL+YnetJOkBULTx8hXM2XqQkB+p3d2Gmi/EaCJl8oRm3u0OPZXvrLIK9v00zb6f6/+xa7iZljmAf+8b9TKA5B9IncuF+kNP3WRbVSoMu44zgpGQ05xvnDwd4j8k8WNZj1Ggx8G4TJ/8z8rFXj2lXUxYBzC8EcbvvH8hBfXdpWZDT7yapbCusVOmIBd83r2PNVGYKjlbNdVwquJ0h9m4r1h7rj7+c6NSkf3qijEJ0F+F6CiLK/GnGxM6Gc1ZiGvupSTQbqMGSrpK767sdaBRNSBrSIwfQiHeRk1n6OPpOhEkhsl14vhcFHyQSe8usb3wfX7GadGR4tMUA7rIxqQdl+w8SBWRGAXFXtBb6F3VTbc5Bq352EickCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd119!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024039768539"
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
  name           = "acctest-kce-230825024039768539"
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
  name       = "acctest-fc-230825024039768539"
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
