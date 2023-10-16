
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033347410676"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033347410676"
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
  name                = "acctestpip-231016033347410676"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033347410676"
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
  name                            = "acctestVM-231016033347410676"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2133!"
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
  name                         = "acctest-akcc-231016033347410676"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyEovFJ7D2VX72mMfQtzjJdgcHzGSuuchXdVv01OUb5WkMkbXnIQRrZ0kqbeL62BfDlac8rHiyVYiBdD9EFufGFgx4m7qI6f2jCiy2ceDyvsWlHArzqVj1X91fNnUhbTIgsPrQVgdt7b/atWPDu9QTQCaHn6oLpPvZl/qoMs3y3M7/Uf3XcI3ugm6Y029XNGTn1wFWLMPEpifjIiaxJGhFSvtyYz9/dVg7fCgka/4lehX+2s/AARfvjZZo2mRnETfgpPHSwv3KuCO4j3APvcSNzq7oV8GxGPmXNk+EAIB2m90aogksNlYZffWBQVSPMdMvrGBjqc7eJnMi9GNDGZtwUM0YM1hXuU15Zk6yfXFW8YKNAhgbK813JmCk5svrlMFtqRz4LfD0FJLmfoiCp89Lja9xYKLHFFdoiosd6LSrdPDac0MPnmQXbUg0LsF/OtmM1XWMRGvslGz9iFLZs05UVJJTyw2UVAwuQhaMpdbfkyFXGsVx9WNtrwIDFGoHCMyC9vyTm+P7QWLH3FjCcUXrUOPpxBSFNtKZY/S1sVfnBfOSNLOcvK0Tzp3x5j8QwpQJCDx+qSZaS7zlkHIvUn+dw6FnonrmJe31HU4scmnL/vnCruL/UrDk1ZYACnpgSFpoQCb6f2225jcBA8dLer0wfG/c49X+3ovdy/h+ppYsX0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2133!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033347410676"
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
  name              = "acctest-kce-231016033347410676"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
