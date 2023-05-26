
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084613346190"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230526084613346190"
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
  name                = "acctestpip-230526084613346190"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230526084613346190"
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
  name                            = "acctestVM-230526084613346190"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2385!"
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
  name                         = "acctest-akcc-230526084613346190"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2BcP/PXdsP+gTNeDyVo+F/mesmq0aM81PWtQpL+HfRd2eHtqqDgjfrWq/+zvpiwBmndK3J16vHxixBhy5F3M5JFoy91GhxizkBYXg0KCjww5zsFjntquibTFxcLheZz0TECpZ3WCmSCAZ5xviRppHVGux5Mi25NA7THZNuyxySQucjtmtZVOpW0JS1QBdVkpe6EAFhDX0f+OmwG1ugAD9IRjvxjAlRUeCtmmca4v36DBqu/z/JqSBPmlOYnVkf6pQsA3WjYijj19DbhKE23IGCaARVc/Q6tmncB80Ijzms38acHgRcewSOAfqYBCCbcjsdk5Bd4FEQQLuu7yH4DWeJ8YmNMopxWgN/eItxRJe+f8wlWg3yVM9pI5QEXyNb1izI5ylo+gzGvsdeAiJv/1pFwSBGU0V/+uNvVBWo0iCbbYVd7Ar17CU4EHWjNW3uVc3Wx8tAF0X9qp901pgM9VUGLFWmr2LIrMhSDcziPq1S1lJ+s81QQJlYX7T7nqNBP4C1hnz+JoZbgk0yOpkNz823rUUJRU0wJUNoQ5Q9mvUQFeVnNdrtOdZ2YNnf+UilfUSF4o2vbDQs2Ul4yVTrIcKg35n+FRT4TrrknJcU/lIvuCpooGP8oDU2/w9IhyZn7OijU7Wl5WYqomkoXBAqj1wEiGeDOK+A6t/8deQFe8OMsCAwEAAQ=="

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
  password = "P@$$w0rd2385!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230526084613346190"
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
