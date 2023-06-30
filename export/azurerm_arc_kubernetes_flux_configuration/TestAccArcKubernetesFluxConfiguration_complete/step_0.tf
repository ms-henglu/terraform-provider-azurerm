
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032702540153"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032702540153"
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
  name                = "acctestpip-230630032702540153"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032702540153"
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
  name                            = "acctestVM-230630032702540153"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5697!"
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
  name                         = "acctest-akcc-230630032702540153"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAww5ft+wcLSxp1aAx8vsrvGA14fV/HA0lOOrTGT39DkCA0o9TD65EtoO9D06CU7RHAxzmlnxvy8HCyaGUta+6Uzx7ihR4l4KSXFt4s5N8STfvQTD2im0QoJzdx+c8VPSkYZ9ZQZxEf0pA2VDsp7mhIZxnPjiICQhzevHbtc3jc3f7kfomFYpcG7f/DAYzlmAjIuRNU7L1vK3wYFNUyaQbsvq42AMs38ST7aGU7NaR6DNxglIdY9cZlUGm0Q9CFgAGfhk5GYXbFr41h7RGN8SfHrw5hkN8HzRoocikNp+yePzSb4bt2dLLvABn7w8APqNXtJ25KyJkI1vDZ/yqq7NhIyEeAyDBrLrJR9aFr9eHs2O4h7L589ls4vFy9HZ6skCqD/zvLWSlX8ikwsG2WZhe2QLdqWhjAVJGCM46ERwPBWp0XjtPLiLPaYJHtI83fH4cwP/UeYk8KSmQmoMhFXObycbn6FJepcFUOFJjq4cJiQsb6mju4QZwYA4qfU/53am+/EkI/j6BeXBWpujPUVLBKiU6nN74+oKkNCKZRzsyAn6qxfoTJ7Q2a4nrdD0U4W2PMzvrWYzWCEdNMuPCLwX2SgoSj64EdHs3+GjCbOMa/hvbqeUuegzCsJApqBdjfPDxZIfU6mEfP9YN8cyj/GGvSFtocLHwTUI2nx72ZPSOP20CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5697!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032702540153"
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
  name           = "acctest-kce-230630032702540153"
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
  name       = "acctest-fc-230630032702540153"
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
