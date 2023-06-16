
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074244807505"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230616074244807505"
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
  name                = "acctestpip-230616074244807505"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230616074244807505"
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
  name                            = "acctestVM-230616074244807505"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4930!"
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
  name                         = "acctest-akcc-230616074244807505"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA9Gvk6NEhdUh1BFyoCcI+5SAWHhWir+v8nY5h/Y+l/kqoFWZCErj9NfhvrjTQo6Ta2HMkRopuwH0uZxHnTr6QcI3PA2jGm2QImroquMvDDXNwwVkHg62aM+h2acjFXYZsa9EQTSKwF8LDioUQoLAVJ3VfwIZ/GWNIEUc5SwZyXgmWCN/MbljYYYG+yZ0IdycmmgFFJqovbEnW5W7OiUc/l8HTon3fYlV2JIfiXndZUuN+4cbe+AJhTUJiGHFm11IuaVKzzNv3En2sUZMBL0KRlquI/iTOVYGO5OADC2z4AP7Y7V99HOQcZtCKXhbsmjc1sUZYM1DCHfv942oID7D+YiFD3xaIgTjI+6TYipVs9PDDYDGZGdWmGYYqIzewvkMptfn5XISpXUQ8yfxPZsK+1puk9znHJ9UKU5aR2JuuPkWgJ5viDr10+liyhry7YAv+YQgFsL/A9E1N3hNY0uJ/boc3Eh0QmFhEitXt8flHVVfcEZ4rZtnIbO9BaVdoUFU+Pw6jYHa79qfeuXKlLR5bcjD6JEuzwfgLlTC9d42T+L7uZZjad8vkYsUn76rG7cVL/D44ZUzXxDBh9xFmB4zSWa9UiXIW1cw36qCDGGn4pskosY80gz12kBtT0RZ4IpkaC3KvmaHSG06DR8PdgxtGMeC8kEV4RAj94k4d4cclmH0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4930!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230616074244807505"
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
  name           = "acctest-kce-230616074244807505"
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
