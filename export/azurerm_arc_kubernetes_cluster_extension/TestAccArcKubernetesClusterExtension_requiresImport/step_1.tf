
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010214188316"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512010214188316"
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
  name                = "acctestpip-230512010214188316"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512010214188316"
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
  name                            = "acctestVM-230512010214188316"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4789!"
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
  name                         = "acctest-akcc-230512010214188316"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAzQGpyaGQzqjDHYzVQOyredv5GMicEe6oaoFxX6SCxloCWycGndJx1hbOF6eV+i5b5Qt8IMKTy7nTj0xfYfYbAvqs+3+X6E8rVomNJASKl65ZUaDeO5/WPQ8Fi5/dIltrJ4thzqHZCRj75GOvtjKuGV39DiWJkqhMA9gXPD5kQo3EFMiS7fEBcHif0caAlj8RngJLMcbEgvi17eBuOgq6+aef+LFF0vHnFNvlRNY7YCrvbywfwxr5xvnco5A/X3hVDONdbo1BnzHIGOOONKsE/6B7bqRqBYJ03AWwlJLemnFnjoXjn65ItLoDmWEje7ZFi7BREUs+euAvecgL2y94N/Rrho+9PsE8WefPZJyXxTNFRFAITyAuZHsUjdO62d5bnCMYYCVSyE1mKcQ46mC3+ggFXSxskorP0cuUg7KlqH8gB2Oqx8XnaeATazveXfFeniEzYvhrxK/xyFUtEqlbUbEhVjk60krsA+FQmzPg65pq2tem/a4jxlw2XXxoMhg06UphIy0CrfAW6FTJV4V8iSdl5yhs4cNI/G7V+XnUa+Qcklw7nEIZohvcQ095uGZ7vJhiNuUDprmw5TIgwBNWB5bnu2X8g5Tk8oOAscp4U2yg9pvBMDtD1hfsOwpWZkKP3d6EALFehpsOySe9mCdnM8UPkZkZvNm04DI6TeHx7AcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4789!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512010214188316"
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
  name           = "acctest-kce-230512010214188316"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
