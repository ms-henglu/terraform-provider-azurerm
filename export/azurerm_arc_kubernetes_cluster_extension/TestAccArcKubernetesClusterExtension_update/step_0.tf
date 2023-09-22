
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053602512981"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053602512981"
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
  name                = "acctestpip-230922053602512981"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053602512981"
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
  name                            = "acctestVM-230922053602512981"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2174!"
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
  name                         = "acctest-akcc-230922053602512981"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqfm0iFYovMkmuSUQ/r0YkFxqLyFhPYIz5JzW4T/vpXimUiIN3czDOn7fbyx7p46aVVFw3Nb2e4I4ahmKHIgBjnp14l8kPVeulClysm54S53D4cKkpZsA2r4qxTV2kDTHbU/o7PYqg9Ab0CeGc+G4oCJSLbetg3I1pejG+Jap1o/4ofIEQ1amqmErRey1v004v5GXwG9ttVQcVC+D153yRl+N0vWyNWm+0UBS6U0QlTaAqM6h+9fOHwajUIbfX4Kq69OyC4DKsCuihhCFGcfT24a/08mebJ+SZSP2xnniR4daEn1tYX5IWQQMb3n+ZvhBd5VXBxNqa4vefxuBXzfNwLmib4vzLOW3yjLaWXHym9XmCyc/5viSaAmM8wl16s8Be+gHgbQvg8vZMY0XqDfVIqW5SfsBI9i1xTBFJ2o951Yl8YF0IKyZeX0h5H5d8PyOfZ3oXaOgNKWPKlCJ6oIFNgFZR1LUpK30qjHoTiEPXNY2VzbwsmOBy182rlmEy4cR9wcpgHX+BjYNywqgPEH7rTpi2Uz8gEM4vrrYa68Zw3lybw8lU34bhaA/AAiRPdYdc3IiUwQnDnQISRTwzSGhcH9QI55Xhwrloo4Jz4+NzZ5GIjXrbAwSP0qAH1La3GOw7RvHyS+ZYZ+02RaTMKZtHA20vMDOmGo3BHH1DhjM9qkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2174!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053602512981"
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
  name              = "acctest-kce-230922053602512981"
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
