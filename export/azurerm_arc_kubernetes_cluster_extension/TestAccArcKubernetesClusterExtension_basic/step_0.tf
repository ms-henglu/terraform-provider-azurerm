

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021507853266"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021507853266"
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
  name                = "acctestpip-240119021507853266"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021507853266"
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
  name                            = "acctestVM-240119021507853266"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5720!"
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
  name                         = "acctest-akcc-240119021507853266"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqKJsFrjurUhF256IdAVhwuRvOtHHB7h9gFsTTOfVR7k3dZOBwcjF60/GYP3L9N0qsNH1Tc5pOSLzoZRh1RRGWqdkd5E5esdN7mvSIdoNeFBYLKBzlfOTY+FBLIavqR1wetXURu3+54gSRgLqAzj/bswm3cGdCUdiKrRdXAzquBRfq01gq7niFspgi6U1novEK6VrYDD4WbDSSkYVJhoV6pq0d9S+dS6UUr38pxluyPKOLmaw3PhAEnbYmiiq0+1CYoTn0to/1Cxt6HH8fgIKL/jXsySDcOIBY8+JTF5J69WZFkUj0XK3/hdCPSsU59KYozlDUU3/XPAitOLHbfr1+0ehaIqB5WwQCLJgM53awA+mUq3LNdV0JSmLbNpzcGcK5c8hH3yq/QMqxCgjx44Z4GBe7t0lVG45o8K2qdd/I9sTSbHAzTCKpFDX6j8SIkZXFeFDt1M/EGHbdy4H7O1LpG2QIcMhAlh9ZcYQIDP1VE1TnOHtgnj1s6lTZcms+cg8bFWPRoiIsNz0kk2Onv0HFoKSbXj+XCey2s2gJI0eeP8UV4HVD1LbUKX+HR/AyVgoQuYr9U82SnPYlavTDQM6Hn12lCxg0TChqbLA60FpT4jIaEd3MHbDHqNvhCNCw2RvSki6OW5Pq9+EMe8+n2Ow0jJ5HEu1F1fDbP22LKyEER0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5720!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021507853266"
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
  name           = "acctest-kce-240119021507853266"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
