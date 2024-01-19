
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021533786526"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021533786526"
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
  name                = "acctestpip-240119021533786526"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021533786526"
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
  name                            = "acctestVM-240119021533786526"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6993!"
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
  name                         = "acctest-akcc-240119021533786526"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwaD75Gd9MIuATIB09ZoCPWkstJ1R7lW6CQON8gkF6yqnEO6+sIwaAFU9ivVLsSZH6X/Afnyq6kkMQrFMuRaK42L7ctstXmTS9VJp9MmqLGBjCG0Kt/0qn2vC3RCpuS1FwzeGPbXOR9oHT5a1mbWd1LvEZ9/z8xev8N4K5GYUekggwVZjTlw96Dd8CtS0MGyeFKkS5Y7Wcjnfx4ME6Bk64+lOvolfoNWAJjfBgiJSzwkFxV63xkvs9iKFfY07L5uPi7lKd6kTIlTG/E0GiX8k7JH59GFwdUMPLu+QrsJ5XE7QWA/4FyfdTYoa57sXrKsdxLNYSnVaNlb6bGQcY7GztRTJb1eXmXEtPzLWUL/bcAglExonQ9GyQf7ytBz5k9s20aZjJjPDxW5pM9nqa4jKAjF+rLk2gFaalk2H+/oifR4AboNQ8gLtHZkuySucr+7e1IMbvZiTZrE3PtJ5ChrHCPy9aH3L/yvjbILQJ05zuQxtaStfEi+nN6I9tgVV1t2QDyG2NJ/RjkWDVjVLWRCjeEPRuqvlSG39gGaGk2KLumNi4hZJKIwbN7MNFPhXmAC25F6cuNrFekcXAfZgrfGsmHQa5xV7oh08PuNltOU7ID/kY8J+BDfdOwFrNVjEFqXHoPU5/hThkWt4ScmfDIyDim85NfJ9mgNbn1wapExCeRUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6993!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021533786526"
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
  name           = "acctest-kce-240119021533786526"
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
  name       = "acctest-fc-240119021533786526"
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
