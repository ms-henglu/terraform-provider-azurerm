

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014441094498"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014441094498"
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
  name                = "acctestpip-230721014441094498"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014441094498"
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
  name                            = "acctestVM-230721014441094498"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4121!"
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
  name                         = "acctest-akcc-230721014441094498"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwOipHqBtibhqWuHmdz2kKNChXIjOvXQJZ5gpDmjcbmTnJWBPBGqfwhsvWlXmJ9ZFkulN86oJtei++EAocc/zo5lHz17v9Hq4uaRhSzNnjky52GKwsxK+Vkc87p6caL3e5aLA0BB8qgrmqStcAKUk0NESCskjXxfE06f3lLktvBi7YXJOCHIM2JXxvy2SKuPhjC4wFiTod37bzyrp35RpJGB6ZHxq/E3XwlDkBbRRk9VqF2He3ss+wRC+chiKIVg0YFJxULZOzKocMFJOge2AE1S/URp5Et/yzW2AAxk6nwiTYY/HRH0WevSZDi3ofVrXCQJ23UHpjpqc1+MWN577JwLdKer1DrsovhK3toTeINURQm9WpJXXOLl87hXccmWZOmOvGjMNyekt9Vb1LNDFkzVPM/9HheC6lBUea44KYqHXXW2Q495uSXvx4AT0mv9BbUtdH1TUJHL05sEklkaqO3JigZ/14FTFXpIaUy2xWKm8wtZlXTUskYhh9GcQcdvG20wMfe2sr5UHEA+GWjMOGpIiiDByoUUPsYd0gNEiWVaoVA7cL3i3xK8y1jgewNVNSDBEC+G7WdPAcwFiXDD9TAmoiMnhSIt9YjXlwCHOTrxLPKnN+ai9Ksx6eS8K1WXywoKySWHTQDNLgsM5ujK0+7sSmTURYUh8zsyC/lACL4sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4121!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014441094498"
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
  name           = "acctest-kce-230721014441094498"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
