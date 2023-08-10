
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142945324935"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142945324935"
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
  name                = "acctestpip-230810142945324935"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142945324935"
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
  name                            = "acctestVM-230810142945324935"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7766!"
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
  name                         = "acctest-akcc-230810142945324935"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8xTnJczoF8GLn7OW2++KbpIAVIlOQu+cFDde1kN3Eyn/eY4Cj/olMVuuVAmCAx/zrTZG7ZRZ6eO24nEeJ8IrJjxDkeMCnDp9/VwG8B0mgo540Zc2pohcGD7GanP/Zkkbxou6sakmKSezgM2X720vyDZfYOJQ9QFf/irWEShnVJaq5rVDbWQNcddpKXNyVpnq8V/T5jsicCE9VtbBfQwoq7zACZKAP4yoqzI0VMTMNJQLaCwkYiU/EuFbqIYKBA4m7FQmKBnYBVEwEvvtyjFzzmYZ0uMNKJhLgAw2M0rqd1K0tec8S7RKBkCd+kMhCq9eqZCXzEKpugST+bLolWsau2Tl7/x1WZoox3+0WJLexYZnc26WTGuPfcfDj/AaKxuoS2VbOh2j8MLKopicVDANfJcfs4YLu11XLpX5GEiiZH98mwWMswGSZmn95zsEyLeF4zr+TGUVLlJoyRDW2V6YhKKV7W9+7e6sGoE930LSmO1iPwY5SgcMY5r49cRHil9MBcDWQva02NyI8wz/bruDyHw49sgreOefIAEvNrP2rgxgzqp3yNpBRk3c2Ga2Ucvdz/Sm6RUyoO7r4XPSEuYgaJVcNQOdJKiRoq6qgFfoMlbP3ua7zfwN/J30n8oZg7HWcVsHVdYlypaJeUGIKjWdRKGKusQLgmm6uusur6tjaR0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7766!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142945324935"
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
  name           = "acctest-kce-230810142945324935"
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
  name       = "acctest-fc-230810142945324935"
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
