
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011137556379"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011137556379"
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
  name                = "acctestpip-230721011137556379"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011137556379"
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
  name                            = "acctestVM-230721011137556379"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5329!"
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
  name                         = "acctest-akcc-230721011137556379"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtnhOzCmrdqf8jhLFDUFroRWLJdVsQPcGlXCDd9VUkiJb36T0zxD5HNNWJzbiypm4mhXfg5CeJ6mf+qDNag8XMK6SDS0LWS9XqVe/FMf8utlAcvMqkyTydNU+Q6cOr3vawk+sa34/PX1fUEQxqbbIASa73AQMA1MisuZWi8y4N0HdMhaqOO1MnmJ9R/9AuD88IkLyGsSqqP9A3zn2tqXi0vli4Mk0tE5NNN5pzCsdltPnca6Otr+IllszwqguaHX2rHPamIbHtzFgELY/flTEFBU2WjbgR0xNQLD7V1SSKsZ2UYD5YBfXO5Fz6jjcg6bjaFtF7/IpDzxZ8V/MrazpYujpUFoKtZk9yf1mJJYK7nK0/QsFMbYe5o5zOBX3pcxUAa99ia/ZSBq0mq2vUv1Du4S7PGfL7SlE8dV/abwHDuFHKxZGmf7zsLcVWmuj2x+lXKSxW8028T2gozuNykNZcZppgmCIjuEvKb5YgwaG2mCVqRCzpdVj6UzD7Ey6EBPLpS0hlM0wSFE6DTx9LuK8saFCNWlEwmFg7lrVGDCly3lLYfQslMcwCP98Jyj6aWXkNPi01PTjiegP4JeM/U22hpm73OlrVKGKtKSJ5+2KTsD9E/DT8uXBSpFG5l+tJbTzSWFyRZ5LEWofyR8tKsWRsf9Lw53Ftos46KT2I2nkZhsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5329!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011137556379"
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
  name              = "acctest-kce-230721011137556379"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue2"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName2"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
