

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063240498166"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063240498166"
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
  name                = "acctestpip-240105063240498166"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063240498166"
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
  name                            = "acctestVM-240105063240498166"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2252!"
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
  name                         = "acctest-akcc-240105063240498166"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1kWWpp4FntvI/IRslYzG7IAgFSF7xg1gbwOiVoBs3wdX5COQmUmXDiia6VH6zUPS29/7eQgBL7N6iy+Yp8d1lTxHBl9EC3UdlnF0s2F8K3FtKyl369Vqm70iSq6719kBlwFw35fMRK9NthQxST1t+hBze7KsyDdAHlcq1PN7nQLdxxGRu1xtIYpYYQInmjt/oQr/Um9dAoSqZeBSUG0pfG5tCKS8/52PUIBnqfWueDM8o+FXpvvxupc6DTlnQkKaTqIPJHOszhkKseG9GsRTndG01g8bDHTWKT5/kBGMJZinv5a07Uv2Mmt4Q+xMzTrfmynhe6kmYXwxmJsq9rrSrte+cma6rHn8Iy9W6KSHKQTAzJVJMSTE5XJswPLyhlFvfd4ehQZcebUxbPoaQJIYjneA2RSRaPlX/2qPQeEevkd2sL+zt2o3L7RFAMY3N6sPJlbn9MxcT/oXsH/vT794wf1zsYOnY/0BVI2GOz56ec529PnpyrA+88vrCmiiwWbIMixhRx0oWpjTKKytrp/jeOvUTTPLKSGeziehf/vCn0WSMvESla213QlRIfQzELRImtYMaLSahfLZILO0dEvA5w2x4K4r5gKdglGA3YvhhpHvBdaF+z7aDbfPRAHxeNZ5n2Z363Gz09jwkIYeAVb24uprfMF3UtAw31zaYhoItHECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2252!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063240498166"
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
  name           = "acctest-kce-240105063240498166"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
