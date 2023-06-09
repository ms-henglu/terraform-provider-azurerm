
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090833415483"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230609090833415483"
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
  name                = "acctestpip-230609090833415483"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230609090833415483"
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
  name                            = "acctestVM-230609090833415483"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd257!"
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
  name                         = "acctest-akcc-230609090833415483"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4yB5MAbIyM1doVYKKHcIC3dYZddtYdxqbs+rfHBJyYmJsUG5GMeCoT65L0BkHZOnmXmvffxWre4WAop5KgL70RzdkSkPFnZmMUllhHHsgRvEln/LfO0DMq2+KhXBO0pdMo+MNkfCLa9MD4m09Jd7VMXeAFNQiEWkRV9rY7IzpGAWPA10Dzmo7JU6z6QsFZzOulJWH/l9ujqlVyiXCocNvhhm/LjPqUiAtRcuwgfwfAkwbA5VyaMCFDYcjBHx7VCSugnBhS+s17ViepfF/+UQu5VX6rgzqw7lDxh8KmSXv3/IDb8GmDCOt1/Wo7u+OQW3OhIRGODCK86+y8bpwFpJkBBsO+LlbM+foE8N3Sm0ceL3huW4h4ZWYoO7bqGbKxDXfFCs4suobDUeN8ng1tMMi+opRv4SzazCkZJX8pWC89V2O6/kQgZzhT5EI0peCMYA9HrF2U4Vj0SISUbePdQVsUQgywyx2GAEkx3XQx4jdbeRbCH36+/ZJQfnXUW1CJxWTj66qqB+gePF9U/38X8V3ptyLX5nQh+79147vmH59h0rM3P385Ll+PgUVd51GeG4pm+SUSwNPC0yh83Q8ZkML1usO1AJVA9wUaJFU4WzcvweUS4Sjqn4iTcZxNRlRs/VqUfpwVEJZKK621TK6nLhMonVFA8WxynDDURvPzPZpqECAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd257!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230609090833415483"
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
