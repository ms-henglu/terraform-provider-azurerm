
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122308305200"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122308305200"
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
  name                = "acctestpip-240315122308305200"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122308305200"
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
  name                            = "acctestVM-240315122308305200"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5881!"
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
  name                         = "acctest-akcc-240315122308305200"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxl4g1My9a1oEm+/sI3kwtuL3pK1l9Ila/YT61fhR3wiNYPYLjkmdM+zad4/d89ZisnOwju+Y9wyhumfzNzJCirIMKuK4CxonAMvPETNVZhO8wTUO/G1Obk/VRSUy2Q5I5kQmGhYQ6v46XFRr/QcTsGWPMTFl0v+u4HBvOBTq8CLKDgQB0r2mC/PdwtwDTvp3WjIzYWpHe9eLfdJGgJlACTS0BC3cFfv/xWU8HxxyGexVNT5TrP9rZBPDBnnfD4wJAcEtmIrvZrVvZ4T/lXEj0svqTRHVxRhvFu9c0bBmdmZFEPKGF1UG2sAdkmurp8zDFPujjOhJt4IwgfHSscGiw1vzwOe5bDTrHVnI2Kc/mL7/VVC5Phqw+4fmWguadmwwRW5NF7qwBCdZruC8d/QnTbJRB75UslIiD1AmKIidvp9EBH40W8g7rYwR1DEfqhWmaOSXi9zvxogsvRWpu4RwB2pf7UZXwY3SD8C0m6/ggxolXbPti3nL/T5W6fl7n2CWXN6tDYbUDmSVgF5YQBifJhOh0i0qE5/xcGtpDYNBnGVy2skrJSHCirnivzsxfgedxJpt3ryiZb8Nl564teZCMYKWIgNXpITYoZAuY50eKpxmIHx84NOZ24dFgc5A+FkyorMHvSzGDRDiB4pmXvcx1pjGBid2x7oNMUVVZnFlYokCAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5881!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122308305200"
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
