
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032657140547"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032657140547"
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
  name                = "acctestpip-230630032657140547"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032657140547"
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
  name                            = "acctestVM-230630032657140547"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7231!"
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
  name                         = "acctest-akcc-230630032657140547"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2eDJfFKbUktnRR9yupqOgp4h9GOQivlIoCVVbmI8VD932wqM+wAHhUfTNMeNWhEYZOyPSdoKhXjaBqthoPqnk2QanHJbiNdwUOCWsamK/WTuY9moF+PEH5/jSpA+TmceIeE1iZqoUqj+ybyykxkJxGDnjuFxmbjzb1ItaNxAN5RU/xAaXF70WhmRvTenlYKuAxYOMgiEkIcyDiQ8O8pxTuU3VAL78txTDOKMK89XiAAWXLVMuR849CcRapJQ2nwW0sVIsTQEy2MzOHnH/S8pDeDZFLggILwn6oSilxybYlvWpG7ABBbLtLt0R2j/8xvFcadIsVJWpxQg6SRxW7+2KD0SqzO15E6w+g2m9TL1Q8XexFT4lPBbFu1bTaQxkT4Lne652YaGVNo0BoqmIb0Y5HEIjDL0IMyCN87bGUegO8In+/6q8Bv9D3QdQLCdXzqme7wJz92MAvE20SxBq06MoTaXyw9qu5Q6zWY01tOkIp3TqosW1BPWxJ3QrvUL1AiOT5xxSc4hZB5zDXcImOORNknUxPnLYatJqQu4OUjaqMsAT98N0hXKWnWHmluaucUlejbNwrNVw+4L2hIc8D22GjMeb9D4toADUTwd8Wa2gJM8ZtUHQiRC3bjf6VO4Yo/73RgH/AcR6fRUXTKU7/v+WJJhVyMlSXRJmB7ZqLcAY5sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7231!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032657140547"
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
  name           = "acctest-kce-230630032657140547"
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
  name       = "acctest-fc-230630032657140547"
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
