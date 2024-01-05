
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063306649347"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063306649347"
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
  name                = "acctestpip-240105063306649347"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063306649347"
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
  name                            = "acctestVM-240105063306649347"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3052!"
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
  name                         = "acctest-akcc-240105063306649347"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3Lo2/bUTgcixNHKHIszoJhSF2e8F7ohGm4miY/TD9cOUaBXRkYWXsESP0OEc1TKmSO8tJ2SmoKJZciTQ+t4mO71QoZAWfIL5lFfVVWJGE/YSkgu5ZyLLvAGjwt6I6UmsUJGeEembxqEkH+pWkWta8VABU/jHCeuGV4uO4+PHHxGOQuv8rFgCYoher1avhRJEOSaELoiLFmrSuwsEHbu2YfiDOwXPnLuyh24LFhhETWr5mbay+JIn1YX8Fg8hFk5zDYcTVaEpRCDdbr5lGkHkite0bQwF3aJYGTDi9PlCODGFxse90Ad1yuiM0LzmMwEZUSSpq9Ks0q3+BpfI4xKz5VGSl4E4yKjQ5HMnYL6Q5DldTHnalz4ZIfg3ssO9YmGiT1rA7kfOJ+u/4LXAP/vWvXZL2FzsujK625CWz0ZG83TTryZ+Ymaalt7P36nJrzbJvYl8ee30T26YNshRo7/cWtqUwKdsaTmbRQstmrs3y2zrkS+CQAMpADiPkjp3r8dbcadNWV0Xw0nvy+oMxW2CfqHRrHiqGq6+qfGqRzUINNlGQVeAfYA1RvgzHHnY5Z48S9ExOEWFeM/OclAQakPWEzqwDM3QUPqa47pFh+iUrtZZDDkj7jWMXLmvPo0DSCQagETxoLQ3kbOIu2hcvnYkRLeaZzJNATpV3lnKheBNfmkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3052!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063306649347"
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
  name           = "acctest-kce-240105063306649347"
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
  name       = "acctest-fc-240105063306649347"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
