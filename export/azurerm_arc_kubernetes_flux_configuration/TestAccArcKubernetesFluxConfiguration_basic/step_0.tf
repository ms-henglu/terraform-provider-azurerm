
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142943432777"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142943432777"
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
  name                = "acctestpip-230810142943432777"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142943432777"
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
  name                            = "acctestVM-230810142943432777"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1521!"
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
  name                         = "acctest-akcc-230810142943432777"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA7RsNvvdJ8mUtuL4gBe2pI9cXDW8/GhWFfJD1/WHdbw/QQ7v/vl3XKSo+tO6/OVdhTNIloVfaBj0uTb0uME0/xwbj64hASo+vkXrpDnR+6Pebd3Ct9YhM8LzwFKuGO43v/RmmpCMl1cExcbb3e+KSc4q9PaD5hRpDLprx32t06i0erE3nYeYOEjIzjcs26KLch9f3SciaE05u+G22Um3pcmUwOY1x7ggkZgtJM/tfwWmIoQ1SxyZ99dWqB6YG7TuEkQRVlSRWkYMaxY6q4cltiHqPnp2K1xMfhhErWmjdlaXXUC4HTG2u6sXXkJL5lPl6dVKXz/UyFHB1GDrm4iBTN8fyt8nIz8/Y+goEZbqNIk6rii4Yt8j+fSBSuOoiO1JcMWKN/App77lQlvItDUpxYYJHoyoAUJ1VoSdR8fjryxKSbAcibiL1sRPb+7H6w12Q5r4QtcpuW09RhW0KyxTC9v195vFFJTgWmQAACkP8UWtOTg0Mq/g5hsvwObuzvQ4C0GPdhcx7mspE8tHp9csWBwnQZ4bIjiu6LUGBVSstcnwpL/Ty1GnrUuofLMWMh9hQPiAEdmE/trIzaXXKKw/ibgGvrz0nU6d3a5cJfFsy7TGRJzOb9ppw/M2JUPzq5H7p5fs7pHIWU6ebjMoKP5nGqAmHgXiQ0KaeLSI5ItpY5CcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1521!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142943432777"
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
  name           = "acctest-kce-230810142943432777"
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
  name       = "acctest-fc-230810142943432777"
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
