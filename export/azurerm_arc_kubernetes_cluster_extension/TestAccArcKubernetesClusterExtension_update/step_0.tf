
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024027594302"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024027594302"
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
  name                = "acctestpip-230825024027594302"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024027594302"
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
  name                            = "acctestVM-230825024027594302"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2600!"
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
  name                         = "acctest-akcc-230825024027594302"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA50F7ljKMwey7ioWXtX1v0JcS0tJcu9EvNYQKv7/Ndu+mue7H9i2xNsQeUoxA6hKP3pYPq//hHuzHUWeQX9m9Edy6CxrbjTWqu1ZXUGt94+CleOL0Qim53zKZvLfm4+qYW0KPrfXAxOlte5yKFrYVyw1XZbC47r5t47h2V+ye2r0+jbsmcfaGalRc2c2y/+H4HrKUDEaoJHtB3KGC3MwUI/tVIH3jw0ZwpQxmy4HFbzAypUGGMOAA2DkuA277PRhF2HEVfjBUlgUykjkc+JF3JyY60pyv/c1mN7h63d+qiwDg+5wqJOcYRM4Dlb+5dpTtaJY03coiniJxMuri7bloHl+TKX6/KVgJlaBWxFyKPCfXhKj29hMXV1ggYUAlclIZd+KSzsmZTybJZ8wtgdGkYGRgzR3lDaCFjQ4ZouzYJUbE01G6lT7lVLufuWotxFeiDryOf6zhn/DGfF3YFu7vPRHzLPP1zntBOA1No5FeEUTw3aiDCLIeEmeSWjQ9/Ql8c3KK32OD5VoAQbQ3XFQF4PNkc12lYbSx4CQjiTieZsOrd9YWab85hRbAw0N5nSypb4JoXsrZgR6U+MYCnXyYayAryfh1geyT322KVgn/04AoxgFbIjXXsrnyoQjgw9jA6KKxfwljvT2OuwiM+1/krz9ayqHqUfqXpHLD5CvWfU8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2600!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024027594302"
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
  name              = "acctest-kce-230825024027594302"
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
