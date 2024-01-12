
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223927956942"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223927956942"
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
  name                = "acctestpip-240112223927956942"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223927956942"
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
  name                            = "acctestVM-240112223927956942"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8267!"
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
  name                         = "acctest-akcc-240112223927956942"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzmOmFuyFK+9A2rw5w0/TNTeD2yizWfu2uQ/5VQi7IM5xwzmv32tFF1b25iidnZHYY6jIt4fOHcEf30p+HBuOdqezSZk2RW7j8J4156yeYR+4KyVJQeRyIhOZxgmYbevCPC9geNu1x4OPQBUjAgC6LngS0l2UTTom7qyeW1nEGIXm5TpIBaQHyoY2GM94+UNQJU/icX+auBtmFQ0FDRZVGRsBe9xJ/BhApf81c8wzvBYZ1bXYWcKaz0fiZhDOepk3GR2EhXNoDMeKnKzSnC9IwzMXOnyqhsvd0wNJJAj07QjJzQI3IWhkPbvTMeA8KVCCSXlxik/N9x9IGcY4hYat+gFp2p2vXRrskXelxhJzL9GcZdK1vm7gjSblnTBRUgJKFh9RkeBYfCgxDoguFjo1uCAzHPN+ZkWasKYnHVjRtRwsdgYci0JuHzKXD6WOY2/CkVUVuyMa5cIAfKYjCzqwQiOF/4dAO/Dl55995ALXBet3HVwxcNO5SEO2Cv2Ktqm9PYt4rX8yATrBQ8L76jXEX8NkNvFtle8I+rRSrsk3A5dBDEfeNY6VE12VtKmhNPLmz37N3FL9s6AVQU8ARcqnZn5pSN/mWA3gGHYcak+u1NQxZeeSfSp+BpyTVRvy1EBlymLfOk3SJPfEHVqYkt41stK/fjir2m+A1nrgBZmYxd8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8267!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223927956942"
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
  name              = "acctest-kce-240112223927956942"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
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
