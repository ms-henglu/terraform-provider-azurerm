

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024023541233"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024023541233"
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
  name                = "acctestpip-230825024023541233"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024023541233"
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
  name                            = "acctestVM-230825024023541233"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7923!"
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
  name                         = "acctest-akcc-230825024023541233"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8hVa2rnqzquUcT4g1ccetrCkfX87HrpoYsn2/2Zrm/OqfgRcjFTIdklXfER0pzQ0NOzH/zDbrt6IUjvrSuzN6dYU1thf0H/ObOyC40IOvO869G3WrNvTQa0V6cQCzjv4JLuXRzbnZuPYiXvcsA9XO/WaiD+IUMZ6y9WSJDIeNJWX9/6oNqeK4KPuM0naVqGe0vxf/Rvyxj3jhVRfzShWbfo6pdplU5Fyt4IdokV5L1JFmpf0pCHn0Oh+IVz24Y6vphC+IxMH9nO69A4SeypIwUzH/t+G3cC6RItYU+1ATBFOYCJng/5raAPlSijB2kTqrvadKPlx3pCwJDboeJmfvwgwEABjKOrt0ubrFkcNDcz2W1XZHcwQ6DOPN7Dxou6XnP3INYDt3jmZI40SHeDrWSi15OrVbpABvntIWaOj8QrzJ7Esr74/XyvFglVb8YCZTpC0+45rbXdYvDsJJqOKrxYSq7DORPH+lgdpS95N4eIPiBoClhOVziM4hMDSI9I8OrYAUEy988PJmqUUo43mbKir5iV+pVz/eNeiyWY823pH0Dz4xbItW4nOeDYpyTrQo6XDuqClLQbsnF6IjwOmwEz3JgNSIULXvu519Fm3I7q3HDwuZ8AelZyx8eHylcPH7S8b15aCa+xfL1TrrhhdHTg3MhFfeNr9rHKRemDEg78CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7923!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024023541233"
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
  name           = "acctest-kce-230825024023541233"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
