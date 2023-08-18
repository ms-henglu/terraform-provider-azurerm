
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023511462887"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023511462887"
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
  name                = "acctestpip-230818023511462887"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023511462887"
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
  name                            = "acctestVM-230818023511462887"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9074!"
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
  name                         = "acctest-akcc-230818023511462887"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0k136Nks+2u5utJsPqnN+bZ/Lq8FCJ/nvPQiXpKk327z966Kgktd8d3n5Kwq1KKvAW8IDqrD/LKJG6MQVqKaFL2ecbG99AM0LWeipfFrkDRo4bTRjKFirhz7KzFIjWaXuzwFieczB2yLl33Pt2vgYdXbtZwH4RT3/ncqUUzLFwA+BX8UNOUAYj2O4exP2lYuxQIgNo0qn9WseFKcOEQdd7oYRvI6BEjINW/hKrgQwt8hCrwBRVQoy/+trl3eePzaueRwEsxcDNS5BchNQXLMPgqXK0INFlAyuhhsRmKK2aaJMuLT2YeENQYmULsI9pK42JToZUZvbEBCki4XqJwKqwSPxJi1YeFiT3pRIoXCcCQt7KNq0eoeUjZ94y5nfm6C9YTFcVuuuGJdS1Z8ahzkEtt5w9obXBa8wEtVbBaWvkZ1bDxwWjdojdU6a1CREXqp7DxXJD/kWkydmpwAtdEfeQyW45UMdYvJ/DLP/FAPus4nI73T0ulUaDSAgydFBp9ipnzyB5e47ClKOXbSEQe27Bdek3pz9U2XuX8NomgEe7oMN9HzDSu/VS6Fhbifp25HcIkHg96aT3Axg4KyWVKMgksgiv4rWW4AZl02PCX4r312z0Ig6uVdTGAC/t5In4URW0mW55pbKMWkijaHDDlwbCDIKXRwzSsJeVodR0kDfncCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9074!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023511462887"
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
  name              = "acctest-kce-230818023511462887"
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
