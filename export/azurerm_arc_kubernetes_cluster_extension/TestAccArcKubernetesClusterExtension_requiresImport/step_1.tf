
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003317373021"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003317373021"
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
  name                = "acctestpip-230707003317373021"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003317373021"
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
  name                            = "acctestVM-230707003317373021"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6342!"
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
  name                         = "acctest-akcc-230707003317373021"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA+bXtDmrDHcUN3X55FA+27Cv0zIkMXuPKGrMGyaVuqW15LELrS5c6lS/ip/YQxtENpYqZohnELutSqUXxZKA3VY0AuF5qQOjfIhtdXrkFKlm4ZbbOJfTz4o1BDgOw/afGNNIdtjCPr31bnTvvgz1r8+0A4arXWOquxomn6TUJG2HiLYjRY3d/RTj097Wagbv0lrIg6kBsmadhWKE+yqjfNVRPAKw2Lb3kGqDdbcvR65ajAdyxL9nJmTfuKDpfpZl4YQ6UxQHhX11kcOj5zlhUHCSv2QH962HE8U3aSGr0c1S0XgO+HZO180GsEy3UlxXB5JRhmB7YzMnfm8/rs1kxqIZGw6ZkhKmBTRtKR9OfnvQomHK3CcPud1Wq9PFuJHgftz6I9TLx64WhYrHV5PW/3nxYlzZy7b1EjpjJCBnNwhWSX5074G4pCwQwaAfSjtEcTHsNGtxS2Nj/7cLAEs0+v1jCc0FnHdVbTiRHc9aApp0HISAp0T7SeVZexbhsYsYOvfdZun6uAWwKOvqke3EE/H4iiBbW07HOPBAQVq6/rzVWbIvP+4L0aYd+qxpS9Ppp6JujH4nlHolgW13H61FAaN2khSRS7TTHseurRnwxBazOhFR2muqc6lnxepHdQvA6aSPCUADjTExx06h5O/2xxbOSYgeC0McPt4Utkec+IskCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6342!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003317373021"
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
  name           = "acctest-kce-230707003317373021"
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
