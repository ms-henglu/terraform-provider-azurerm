
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090829223592"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230609090829223592"
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
  name                = "acctestpip-230609090829223592"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230609090829223592"
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
  name                            = "acctestVM-230609090829223592"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4917!"
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
  name                         = "acctest-akcc-230609090829223592"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqjrpUKe0QpLIgX7CBIz79+3czG+6HRwcRjr3EYmg8S6mzi0cl0u/PJv8mrbo+JIJHB7PBZ16Xa3hyi43fPk55OgOwYJijAjWIrOCMWq6sYCw1tw8A8FXSHqqsmkmcxxziMkSMLu+9lzC/PAhj7j7LreYjS55kZY5lc61xh0MxIgM6nhfXua7SucW051uYxEcXb9XwSxSniAB2oNHMUPlrvw02Up5RbvkkYBVf0Pxw/i9YuWCFgce1iSJVVjHIQn0y/Uqg6KYgHaxzHvdrzFn1uvuNC8EzQRTPko/jfIQOb30PKZg5WrUoEzYCHjYtPNxFQtAHcA3OVbr+fSub8ugp8ZteQP5MiKhHbOD2Dauci7Cn5oVa/u0aVx/Mrz0X1R7G9Bd9WvhNJhIqMiWiUMMcy9EGi5SkEL8KXuDkZ26km5rFWENp0khre6YRLufsy9xHLw3workk66loT1PpiJW/1kcU8FQcEazS3OyVvm3vLw3Ag6Q1cVCp3U/QWXux/oGGPV/d8sp74TF0f6F7h5jZx5OAJ5EDuiBUM5fTRV0c18B4zUHz4VbgpQ/vr2EXzChw8uTiGINlYEroOq1aBdySnRJ44mgTzIbSjcicVeLbzKtltPvFsA807By/QfgZHZPRZh1TBIRm+0vzQXqwjioA1Hl7gHl4OdzxdWjaRoCcaUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4917!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230609090829223592"
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
