
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090825107765"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230609090825107765"
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
  name                = "acctestpip-230609090825107765"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230609090825107765"
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
  name                            = "acctestVM-230609090825107765"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7461!"
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
  name                         = "acctest-akcc-230609090825107765"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyrWi6/oRob31CK/oj+rT8XpNhTS/yvoIz4MQTZ31u6gcUkpwnHIohGsjGs60EFmN89r4nCRTLGlrzkpAx4vTINsdqyLalaZ8EZca54ZfTRkDpzyhmYtxiXljuY3kVBq/aGBGGYaHC25hlTBZfKwFo9R/FQKdCqyquSuiKiTv6T7itCgJZRZjSTXURZwxBj75e+yovOtaCfFQR4AHPAloBg8hoJq8Dka7xB3NLQUyOPHkw3D59VlstEprxC1iQZCm/WlC1Vjp6pO71RrJvuA6l2ZLAGHzwrvOM9qW8hW+9GwhlorhodctpjVl4OI79eNH7Tb54PwxOCd21Au/Wum6ZpbqTUGcQC/HGvLhefQmsknn9WJgdq3YU6Xy2nW59nWCZHgMxdZ7Jl7bt7RKHQUBiyheQzZt/WM/27fffeIBaiG2MBRpASutGd9hCS3aPXcSSWlC91v2MWTFMjmDaEtS61r9fGKy+uRahJgx6lsZwwisYVUilxlZDCc2zMJ7G+fxR/woMZD9iOkgAPIslErC0XIKs5UQ8Ui8bwXfFz9Kfb7/5EJUoYJEZpWJFFx7oXJjvCtYYRrWwCTgJPOdyLThNaTWqydokeOZC8xHCknloAbq35rbxTeximRpX5ZEFsdoKqpRSgB6zs4ECSQLbu3Sa24Pqr0mXz+laKw7NidIGq8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7461!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230609090825107765"
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
  name              = "acctest-kce-230609090825107765"
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
