
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060559456407"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060559456407"
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
  name                = "acctestpip-230922060559456407"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060559456407"
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
  name                            = "acctestVM-230922060559456407"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2753!"
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
  name                         = "acctest-akcc-230922060559456407"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuPmTQ8JGgD+HxTGWZh2ev+5HwaS9yhq152x722P6jo/At3x6j1HjC6vJ4LqxsLD5Qv5kfVt0YuX1Vyzno66YDNDaB/A6W/gAurpKVvk4EkzzYp8FFzvrNsWSDCyEiX2apSWpZHkcGCBHAEgwTjSxzj4Swrx6/tC9nHQWBRp1RZHfpWd4Sef5sPCSU7tChOWuTi5f4H258svuW7oijCj5/THwnAle7soSX5hnZ/vKgse4Z8pCvpgdMA4On5JZdaIpbm1wjTSxIlCdCRdttAroJA7t5JnGoJqaqP8qqBXBrHryMvcvJwGBlSj39PZ8W+0eTsfrLUHfvOPNv+Ks+oFlXMu0Wqs6jjlqhAO7MVxubNt+0DEl3RC/L554ZAqcaCsBBbj41r9zuUGmYzoRg2f6UoharClZuLcccsdlUMfD5UwHlEq3PO06T8RIYqH2dA5XpJZp6D1rXaJ6H2Apb39q+AWbuV+g1zY6zR/YMVaYXzr3tcVPsXcDoWiNbA+HmggCC8gVjfygHFknCD8+gS+ApmCffbKUxVDMMZ8wb2kZltSLReomeucTULQxK7+YeFI2DU+NQJyAIoYhEXJn8lWHy/RpRvRiWcSgfsqN0wd0pkpYEd75G5H8YEKvTr61cu8I88FGGDlejjBmVlaXZju6ndwqIKXAY7Gjw+KfgvwPVocCAwEAAQ=="

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
  password = "P@$$w0rd2753!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060559456407"
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
