
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025425440240"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025425440240"
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
  name                = "acctestpip-230804025425440240"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025425440240"
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
  name                            = "acctestVM-230804025425440240"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6516!"
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
  name                         = "acctest-akcc-230804025425440240"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtQryKR1GA1pwPD8WjzVi0+uaoYif4gwmBhJTyHxdL5f5vyrqLOQb+u9BWXh2yPMlq587mBJR+ha/FUvE1kL+bqb/J8IiuCbTyQf+XPHL4D+CV63YJMMR0nm5M7PoLvQR9+AKl6Uptj+rVzNy3x8ADwHgSPLXY9zs7jrD98aOzHafUfwEXrFzUaQAlrUJ4/lTVAHdDUufFB9VX8QlGRVJi8rfWApWQmiPEX6FKRLW6B/5yfo3i8IJvXgNHJT3f7XwDH1Ry5IfqdHOIS1tcKBnSl2+t9Gf84d3/qlsgZcaWht+08MwQ1rqyRe9pB7febkS51ejrD+aTfm1vZYw4xo64F1ZS5ZeGeAEKEutoS8LCc3ls4W4uepwx1TzWrKY+7U5M30S8e3TTL8C4hw+z4o6/bjYG483dEEKNxFlK1eaHrjRLRkTTldBiN35iv5yPwLZdLWoev4CAzCXLCf+7C3dBwIQ+CiXczj/Igzf3QWxkFmL00iaTVTTED3OUYqcYTmbUsG4JxHLI70mnwgGG3bnf/HCfILn4iDSRrL6hRX50P1hhjU9h2cjR8yP6E5N688at21kWYQ1eBIwescsflevw8XmZm/xBbaNfxewcI5XfKZ5NyYXVRO4jobrfJWPCl+H3FaP4ESmjLMFduO05pShM5mbrmPnDiy0jDFrd/MfB90CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6516!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025425440240"
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
  name              = "acctest-kce-230804025425440240"
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
