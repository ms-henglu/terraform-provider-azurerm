
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071322994060"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071322994060"
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
  name                = "acctestpip-230613071322994060"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071322994060"
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
  name                            = "acctestVM-230613071322994060"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd933!"
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
  name                         = "acctest-akcc-230613071322994060"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqPn/CmA3PfzssuYDXs8URy1BIJGCu1nwudsHSoDTaseVi7RLgbtHVyWbUHBDD6r4gLxZTPEbIeZgVHJmesGSIdqHKSep/V9+OoICqwPzaCKcNkNhLJTvXn98A6WOAE6qBGO546yjxsWaxOdGFlI0dFY5v5E12DytPJ/hIG96WGnJvY/itrU3/ujVoWfuFED9C7T0vAYml9FszpasDD6yU7s6N5MqXc3uf3usYQzIhd81Y8Vs8luRj2wjIi0Bc87S8O56jHCQsNwfbrXS/FXAeTrhx/VR0E1qPQ5GBr35Hf1J8Uan5OAJBkPZFeR4NQ4ATk6Dr7Xxvh/kdw+Wj8wiTBla7uMat15ATzguAhqyMZxCf+6lj46HhG7DWlEmlUP0BD5V6Awdx0NgukbTnhY5sjcOe3yOgycjU8ySdr4ygVMafwqNdKjty0nbXhtV3qEeKPRpOhAiXr7loyL8QyZ70D0C7eG6QuaLimrVnqAKJhtxewlpo0bKdfYE5WpMrhitB+4OYNs7koHqJK0c2NIwR0Eeq3e73iRpyr0B+GSKccDeJYDePAqtJ9FWJZre7SUQIto/BkhXbREbLklOtKaZ2IXOQLs9iv69cnEMX3P3fGOx3n09T+09/2IYgo36Z+wBBhcUz9NYZJVpddKWXLwqf2DGDHo+ttEwOJyzgqvHlfECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd933!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071322994060"
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
  name           = "acctest-kce-230613071322994060"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
