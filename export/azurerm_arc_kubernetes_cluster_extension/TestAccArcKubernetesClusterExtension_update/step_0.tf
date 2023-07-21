
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014449526036"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014449526036"
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
  name                = "acctestpip-230721014449526036"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014449526036"
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
  name                            = "acctestVM-230721014449526036"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7294!"
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
  name                         = "acctest-akcc-230721014449526036"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAs9W4/XLnTS23j2umYoX/8jyq/T8Kzm5RQc5LnLnpsqcf17LO24NJx3OgY7ZOGr7cU+vXQmrNvtPuWMFSGhedNy+YqVdCz0aKxKWByWJSr1M4ik7szw2c8W9buRzoN9lzXSc6w/nv3iKhji2I44mNNZ+EkYzyyBKNF9azHw4kd0Ipk6QEdsxv0dajp8wQtjG96Ops5FHhJlAZSOteTDvYZL1kLGTqKlOz0hOiqNIBYnZV0WYglIwxsnlQ5wy0JLsy2rkD3RSyuxe1DUVwjtU/M2tnDSujJJmjhFsd0zPsTAXFps3XoEteZKz8DabJ4wyfp36FjzTqGYWVnVn6FgwQx0LuIOQLvc+3fibiA7zrrorYTxbBnU9LH59Nn0Vc9VCWXgXmKydDu5MsfsqN1eiXr917PifCcx3R5feQV7Kg/KjN/xwGeOpHZ49fhJuuEApitlvT4Fd7AcaGcafiYOdhyWCnbmJtUcjZWulf7iW/5L9nTRiiQ0ngq8JBgRf60a0zAgrq54DSV6buWGiDsZlx8+MZcFkbh+J++Iyyt5S9+NzSleyFhf0J9PwXHhl8NgDCnq99tjD2NNxYbgO1cR/7aCFRg8lYuIFUMPMFAOA4TO1jWi4qQQ8l1J2zpPJ+Cv9uSgehkdyakKeHaHUdANJ6lLjtNUrgo5cHb5jL3uz2MLcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7294!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014449526036"
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
  name              = "acctest-kce-230721014449526036"
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
