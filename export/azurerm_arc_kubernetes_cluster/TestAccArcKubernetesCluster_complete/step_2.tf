
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011145364005"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011145364005"
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
  name                = "acctestpip-230721011145364005"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011145364005"
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
  name                            = "acctestVM-230721011145364005"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7447!"
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
  name                         = "acctest-akcc-230721011145364005"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvUlDZjxgyIQOGX9JlwUNSFyqsW3yBEVzhpgFpXzBpSHs76J5ULvbHxpMiUNtKZ8idX9zIbxKSl3tz6wwJ+LC+9uwWdaRH/6mLcYO7Amciheyd647hI9rjbOW1XLnuplkrOJyhRHMpo0PVv8IMNdyL+CxaMzhTY9UqnnDGFJ5yQvA1f18oLoF+yid2T6zFtntyBXx5thdpZNSlGehsovCpC53X0Apw+msej02mppEI9mQaa+TuqrJqfHGpRAnYzpQ6ed3G5P9Q6y+YVufzvR9OqiFxGiwOr008CqbAJQMK3e/npWWkxtacR04FU9W+lBe/TeS9T8zGupPSoewy4aT4WRxPOL4QwNgfMqqbL/1U84eqrNvVBeygdccE1Szmbi81BUCAwU+RNxhClpDrXHHT/pTMYLvbzX59bAxF7qqltrnNz914wIykb9BLdcF5pVTjwWqGHkmQ+feUpQjy7c+LDELGnDmsrwAwdPHAOMwkRxtT91LuZ1UdCLXlv6EyaS9cqHvETYXjSdNaANyPhlWWfkKF0WrRES9Xvv14OhCB7Z7ODz9LN95XA4lYUMQBzKr0VzZNDsPnsgeaanpj4AdtGz3qDKyW3I4YaucZBayVcPTuhmI+0R0Hq7CCDCl6gWaXQM/H9PqrJqX+g/ifjtE3mql6xyhuVaY6fUzpUgx2DUCAwEAAQ=="

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
  password = "P@$$w0rd7447!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011145364005"
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
