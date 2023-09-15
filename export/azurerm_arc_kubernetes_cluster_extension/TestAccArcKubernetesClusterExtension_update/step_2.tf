
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022856655449"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022856655449"
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
  name                = "acctestpip-230915022856655449"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022856655449"
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
  name                            = "acctestVM-230915022856655449"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4236!"
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
  name                         = "acctest-akcc-230915022856655449"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzzhL1oaVgurFZ8wncAKd0FoIHNk9nXX24qpUfaCWiPxXTyMCRtsgesYv9KiXSBqhZ0gtW7V7p2bHEwL5YlhT2x/oJc/sW1G+4Sf+q/9vo0ArXjlngeCzu18d7w46LQYCypol6YMa8G+X/m2ya04hqo+07Nrz6y/37Dss6dLBwu/PX90mEolH1S0KhYFGaXpi7qLQfLn5NDUFgSB2xSowGx5hJ9E3SXhO8iaKkUGP3rk/kVxG3J5M60nYIBfmfwYF34WL0vcp6XTZUqsFcbXHKUsOC09vz+hKB1rzGAklZQHpKTqtvu5skKyBxNowdH+ijc57E+6RFWvKECZ0V2CNWXdfjKBqKu6GxnnBHnU8o7hnxQYcTmYBDgdhDC8wHjidntRwUzMPcPdIHmso5ifClmQn0xqJfiWDvqEhliSlSSPzj8mnMUGzwSwiMFOsQoeKt0mj81pSw8lKurdQGJDw2e4o2rwKqEHDswtKjWxpvFEgd9NSKDqmNGiHr2NCribl1V5YUb9A0CvuubJg1YOPrk+mQVtMAo3xOygxTmFswm98+oj5DuPOZc+f/B9ROmXljXjsZuImDTVlMLPGUePnSqGWHYmdPaI3YxJUPokXwDVoSq72bwcBRNa6WmZLdcLFln3CDpN/XhfWJMbCa8mq7tUhFCwAYgReLnAXR5OydmsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4236!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022856655449"
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
  name              = "acctest-kce-230915022856655449"
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
