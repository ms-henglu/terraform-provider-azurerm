
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023522781987"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023522781987"
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
  name                = "acctestpip-230818023522781987"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023522781987"
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
  name                            = "acctestVM-230818023522781987"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5525!"
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
  name                         = "acctest-akcc-230818023522781987"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAoH3suhadJhhhAVyCAdrsBHicUcRUIlFjrGGoG4Jwu+uvITEHOLnUX0KuzP/vUbSAfoWKTLO5JPIEycb3mthisbxmyN7UNvNDSfJZOo7fXBGzifyNAoAJwVIQaAzf8+QuqPbdSbu1TQTGsa7Af5hZJ0mLzBbWjh4ni4Mt8fN4mLHglRLpSWyB0l1HgF37h+Xy30RZp95W3wg+SvuRnrwFIhVjEhyVSJ9EL3AiYSb3KTpdlkoasuKuhjjZGikdnYFveCBWrgWQOUx18+VU+ZCOU3/oRQzXRv71paWvrv7ZB19FFQjAjmoWUAHsv59OlkyZE5O/HfKvaZ0zxxrhnlgw57XNNIeZaWf6s0yko0eRLZ8P4gHFrCADFGMX4OU9kLOEND2hEHdKKX/i5GtOZY3dgSaDTqOOmnFDAmIFw6jGfP3qpHgpTrnFZ+rodnY/suAG6j6zGEox9jEmURWYaOFIWK9DCoqngXyHZmeEXz0DDLY6ClNeUuhAasFY69dN0dQJGEby9UIKiiR8jlyEEPF3Nk2WhcMRsMm5lYj5fMVHUIPFXpqmlG3+AUpOI4deTkqe6K7w6jF4cTqoK5uF5WbMhgqiUfm7ZlpoXcAI/1Gcy7YOEALVsE7aBo2Wz3cxkynNwlu1TrJq0U+gd4RTS2B/dGVZ3vdyoK4GI/mitUSivd0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5525!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023522781987"
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


resource "azurerm_arc_kubernetes_cluster" "import" {
  name                         = azurerm_arc_kubernetes_cluster.test.name
  resource_group_name          = azurerm_arc_kubernetes_cluster.test.resource_group_name
  location                     = azurerm_arc_kubernetes_cluster.test.location
  agent_public_key_certificate = azurerm_arc_kubernetes_cluster.test.agent_public_key_certificate

  identity {
    type = "SystemAssigned"
  }
}
