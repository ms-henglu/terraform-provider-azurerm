
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053617784902"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053617784902"
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
  name                = "acctestpip-230922053617784902"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053617784902"
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
  name                            = "acctestVM-230922053617784902"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6173!"
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
  name                         = "acctest-akcc-230922053617784902"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA01h5G/H74xiAsdaS+elyz96V3rdQ55/Ks5jACqBO7ipN3IIoD7EIJoncdBthoAFPkPyqLrNaJ9QMENG6g44/Xihf/gsqVf5BS4HKMvWwyXLlU8rmaE+A2fXtS3GoNR+0l1TS07ObHvm5s2w5VBl9Um/5EkwaX8+HxZ55Iguyz2O1JvbV2Pd3KsPQXOWSi3WlyKEznBccER2Ubnim3/C2cJ3++9pfqkbNq0ZNFuvkHoK3tPW/5lyv52Gm28/z7iT/KJWoMYqGXvXxqBAmBFMcahNZbEx1dGP69XGxrtZazwZcwGckr8QRjzedP4UdLtfD7FM8sKswKmaos2BAUsNJKFeZlrj92QaxahyXb+q42ijgPRdv9dL1+ownLxTGHbMjC/NbmO+8ULJ4yZBZSV9sxt1wIZpPeGN+ouJ2OosVcx6Fz5psIcFtKnX1ljncLCq8qz3aNLc3yAoqGJL2gyducAb0gFyTMzsetnX6XccWCP3wG3+a+g7re1rRIWu6OgcO8rntIWkmXxSdpzNei4X2gU5VHDwdhLbFuHLOFeLnaMdvUVphoQZkMkof0LdVgjqiJz+WNU+5tcxsYDUIO5mYjSIdlSP9M2OvHdUI9uN0+puyVQwVjeSRqxXPzJMOYE8q8P7LgBx6La6drAsG0m64WaXv2VOMDsFRKoPiePxAnV0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6173!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053617784902"
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
  name           = "acctest-kce-230922053617784902"
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
  name       = "acctest-fc-230922053617784902"
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
