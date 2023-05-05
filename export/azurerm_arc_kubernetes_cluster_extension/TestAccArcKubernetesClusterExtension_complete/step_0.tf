
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505045840452718"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230505045840452718"
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
  name                = "acctestpip-230505045840452718"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230505045840452718"
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
  name                            = "acctestVM-230505045840452718"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3206!"
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
  name                         = "acctest-akcc-230505045840452718"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA6ohB4iOFx3FNjvNOLa2rjGbLg6iwBlu5ETOn+gEvfnKPP+ehvux5ayAOkd9wPPeUfLij6+AERyyaL8EVTnTmIUTBbbOYs9jakrmenEXbj+HkQcZ9JGV1vb9JSokF2D1iWJsh9QGFg48XnzcDNtU4PtKNMDwubuNU02okObwIB19VRZJ3d5SMj4sOcCboeRCFaj2GeE1BpkmaefTO7AoBqLzk/q+zS+5sm6N1N+Uv2xFI56tyQSC1eWFWuQodUZ5QTvCv1k6SsgMa/eiUv4El5Tmlgeq/3NJbZYqM/EOv/qxBFxvmlgYZCiRrW6bZ5CRCSn5+Gt0suDcgq4JCZuhdYxe7vEwLVdFFc0cHzeMJeTu/6LeR1dWddx26GrJYN0iwwVOiaqa5DrMeAfYwDNs3n0PCQcD2lG9xKTiSa8CophtcfUAoqHDhE3nnNE/QgbuqLY+U3KUr9ny1nK5v5NhlU3lqZBXXPAfCSxZ1jkwNHk4qoDVtT32cTRwu11d9KoisdtyhiY0mfmxDzl8KDyf9l8ZGwl+5sFaa4CgR8o3CZ27dCzSbaauWrS0xNHelxGWureA9iCeQpW4kkORC1Jzv2LfM+Cz5zU7uuGxzLrOCluKOCpExKzGEXrmecf8pqp+SZU6H3/h8hzorSJimqpt2VrDo8DUcsHVK9Hec5EpVf6kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3206!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230505045840452718"
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
  name              = "acctest-kce-230505045840452718"
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
