

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084557100961"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230526084557100961"
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
  name                = "acctestpip-230526084557100961"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230526084557100961"
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
  name                            = "acctestVM-230526084557100961"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4942!"
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
  name                         = "acctest-akcc-230526084557100961"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwAz4AVPG/pfpd3BNfAB9nXrp+K3ATx8iJ1nZAvYKLn2J9JhRe0He5uefB2w+jPsnzFk6X/uQ5IDEsN1Iqr4HCqksvWF/ogaYT4Zrb285EJPnAOpmFKRrc/8RYDcNwuPuUBsdcamhpb1l+u5QzZNFiC19BNif/yLTO8GQwOYNEv/JwIz3MfZJQo1LwXu2s9J89CC4Sai3Qa/Q31//a/hHBAAk4URrgM/VNzfTDOYkw4A1tC1rPFav6BKaCAugkk4dM4SOtB/iOMAwufdId0J29CgIXIE8779H+gPh/uP+7YeR7CoRX17lhA8u7OwN9+7TGsoD9LMmEgFjO2tId/HNRtYiNpOXAJy3iXAlHI2JOvZPazIF0bMqG8JpD3FBg8cRdDH8DMTQeLW6M1ZTGEFSOOeHrcTSmc2SR0fMxrU4sIHd062d4YU7ztr0sYZa8OFnyyKJ7lQfm0a7ilch2hqWHF8vpPFA4TtWlnCt/QBsg3xlsVB/Uu5V3WwtvL/zgA31IvWWnEiaLPfrebDdFvtNy4MVy1Q/UVlXD23/bpGc9riKCMhX4j2wqefdJnt86NNNw4xQDfbj2Q9FnuefeGhvdiZonoVQtZIxp5gh0+SyNx+9OgkIMdSDknqjpa3OvJUwFYpQ/dRvjGcEMob4B0lLakVHouOjGiye+SSdpaYmdqUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4942!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230526084557100961"
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
  name           = "acctest-kce-230526084557100961"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
