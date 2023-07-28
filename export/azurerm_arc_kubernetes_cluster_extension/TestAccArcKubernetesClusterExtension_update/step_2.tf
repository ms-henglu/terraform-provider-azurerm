
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025044731887"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025044731887"
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
  name                = "acctestpip-230728025044731887"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025044731887"
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
  name                            = "acctestVM-230728025044731887"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7030!"
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
  name                         = "acctest-akcc-230728025044731887"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvzPydI3hYmPzBZ+xhZghfIhUfSHqILx52CFz22bPnzS+2dHjhjkHGxG550jAxisUFrPLm8pg0xm9kHHgO4JJRtQzgxiwxfBQ/XY5H8PNLHZk5UZbo2JczK0y65n0xshFm6gh9aZz2N5UFS57pQOEIodRuHXCFBauFSKNVJxQIqM/eItB1arrouQl9kkUIrR2h2RKKdzHduUjox3PPQfzVgVfA21cgS8uP0NNrgNESMypXR6PwBGuPHkEGALuT5Npfj8pyQgjBLg2Okzw1nPy8PI5wCrUPAq9ergc4B8NATNxsqi2XU82gHrkssr4vtwTAWZ2HnRQjFL3sZFSofrIF9XJIl8eeBRa7CAr2ObyxZjLJM1mPOkdoXNoF6IGggaAdU8PacApncpnJGGzKses4WvDvLh/x+zy5IR4eeg1gZTchQF+6H9lnn83JQQ5boDJbePEdNDgxgcj+yd5tAzx9sE1ZdK08Wy/xHvamjn34AOgr6f/QWT9ZKVAS5SmCAMSvERxqmoVlHZmGFd8Il4Hiol24nfg4SIestWASMsuJce/0qQzW26nZ2buVD7Z9csydcf2bfJLKxIEXJYOu8T7WZ2QwGclGZz4qfoVp1yKpu7teFq3eJ9yK1ACuHwQ2FmvuulB9oI3Ro0nWexHqiIDiZmIU5fZbZ5N52D+OCP3iG8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7030!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025044731887"
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
  name              = "acctest-kce-230728025044731887"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue2"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
