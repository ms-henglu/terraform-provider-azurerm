

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005938885257"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005938885257"
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
  name                = "acctestpip-230707005938885257"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005938885257"
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
  name                            = "acctestVM-230707005938885257"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7659!"
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
  name                         = "acctest-akcc-230707005938885257"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4vrJe1ZprvcdhyAN8VUBCk5jD6A9AggYpuMvhGsBUZWQttrUa1x6vmmkVCbiMPKeDd0OfSqlul6EGyeRJYJh5imStUDON7OXpSvNX5RazeiLcTK+dECn9jzFc9utSBfegBkDwMuNVtro15PznrwinpLE/loWN+XOrka1PjRg9gBOBubMPUNcFGWsbP6KL5GDUN/P/69qYyYBs4UCuWio4YCXCM10SeJxEvEEW4V4BlVVxE3Isfiys0Hufs+PNX8QRjsUF9KhEAVz7ewMjGtJ4oU1YUMsABBq4FBKOJTwsLidkZn7swAqxVjBhv9kJV2ydvfuWumdu5Wgrr7fEdyluSdn0THVabaZiuESmzwhnjALlaWJgZ984/wFizW2hCvPWHUClYuG4fYiQUGfu0al1XvFAhPcnja+46MOHagmY8VDoNbRiyeaDQ5Zedj1UEQanNmpuwr5zb5EQ9oNtj49rQk0jh7G9dMSMlRioZtppjeGbEzpRKQ0nU8RRZ1c7qt/l06bxgh6tzGKax4m3G/I1HCzsZw2TNrgJqxxd54khx5BSj+tsmeizPfQfbqVCRdRm1Y3vTxc168IogtIyhLCdF9oDiW+BlgeFs+VI0PKCmibfBMpILVQM4SKJlAjgClphHn7sEPEMAV8JSqzMeSlpmB7m1ZW8tweJ835U96pJx8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7659!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005938885257"
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
  name           = "acctest-kce-230707005938885257"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
