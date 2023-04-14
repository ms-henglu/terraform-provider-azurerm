
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414020742445636"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230414020742445636"
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
  name                = "acctestpip-230414020742445636"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230414020742445636"
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
  name                            = "acctestVM-230414020742445636"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9128!"
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
  name                         = "acctest-akcc-230414020742445636"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqrcYp7PLbdMefKHOx9dFVsvlXp7MSpHWjgdBF58W8QmcjJLTG98NjUW9rSJAFyoV4997w0QZiBj8DWSQxPkrjkMJ4AjDMUzr2PIOSUM5c+e8+NaovuQW5NT8Dp3A0hjpxlB2+2BRkqMnVNQLZiKxSzc/j+plJz53DnupPCDsk0yEUyZRAcFqSGG1aVwtroRoOXCgUemSsSny9EIe2kKNqE+2tte9gSp8/LxbesEqAx1HpAMe6Dnbl6omN+LURZcMs/u7tGK8mYS4tdDwJNMFz0mk2KCgDQZmqbe/mDRjBlidhjokkWJzFWfay2YnyNPZxlXL5JPOYsSmPlqE0/x3PyLVI+76Pvu1Sh/486iE6tK7Tyx/IarrStMZVbQ1DlI4mxM+NIpv5mBDsz/0NHLsUFyvhFIsG0ItXXWPqaLCNsFS670r5pi2JodjfAS/Qeikh4ZaeHPo32696kmM5tvF0mGTIogmFFP9XDUGXL/5lahdt/4bWirDLi7JKFW5ke4gFchzp7MEbgOtR1V7xKuYayr4zg9YKM5ai9CIpNionTZFYTa5hitS0XJV+EwGCgHAvurlkaZEffV/zTKK5v02syeKYY9SWFf8OM1yUv3pBNRDibLaXKMhcLDWe3d20gtBSE1yUx3wVBk74qqFagit75GAURjESuTsFPfNC+5+egkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9128!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230414020742445636"
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
