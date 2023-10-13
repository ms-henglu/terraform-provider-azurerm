
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042912180302"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042912180302"
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
  name                = "acctestpip-231013042912180302"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042912180302"
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
  name                            = "acctestVM-231013042912180302"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8392!"
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
  name                         = "acctest-akcc-231013042912180302"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4aBI7qZ6eprcuygiHKEZjZpov9mJnFkkCZL2JjzoHhBH1wTlKE8r5IsU1Wq9X/is5V89GTb4uPEOpMHFVn7LmIyt5bvVKB5aY7Q/HwauhBolSzNEPNDuwfTddwKRvIQEKPrKfDCfML6plnTSju5RY5Cqk3/5w9tK3jJ8LJiD4qWqtDex9vG2AsMpvda+SxtuyPSBuJMN63s8XqXd4iTf2zyE46UdC1Wusrys20vynntLxU2aIa9yk/cdon6SYPukgR7cFEZWINRWZBfzk+K1EBzJI4uJe7S1DZo/znQAswDSq86w+TuRmZDk5iBZPJqyGRQIHpRNoV/LuG4nxzLzkz12rPKf+94V6HbXSdOJ1BUNszWgvW47CocxBNJatLCheU/gOWi/4YiCkGQvBWG+jdV7KmIhAqBbihjfr1WJD5TBF+/Ou/i/KiInrKnz/8lF/VzD6TCgiq5M6NoRfwBmlRwNaKhGWqOTYkAORoPkLA/622m9pxtgpIpwFxAhbmKKHIrRbbDC4SRHIDWMMSi+jikW0owepQjedTxP/Vl09SIm+Ir2/hFYc+05krW4gHdB6fFH1wNKqhVK2++aNVn0Ozlfg5BebLJNFgP0MUMab3V9W4mCq2cLR8d8gT5gMkZev4lFayNaitoXVVIRz/qkUTwZ4y2zgtfUTY/e5SrsivECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8392!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042912180302"
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
  name              = "acctest-kce-231013042912180302"
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
