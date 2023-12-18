
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071231262791"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071231262791"
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
  name                = "acctestpip-231218071231262791"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071231262791"
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
  name                            = "acctestVM-231218071231262791"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1405!"
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
  name                         = "acctest-akcc-231218071231262791"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxTHXoulRd4ei4jXbN+1/vlublMjOoRONFwF/tibg8HbnSqEe4YdtNLG97trFmYiThXyvSj/o73Ne4M4lrvqaF1WePiDFgW/c937H4JqYm4+OUc7Ah+EJhz/dYpVSxVrLVelaC4MHT5x7FNcdQ/bv2Zbrww7nMeEg9P5v+S6Tg29hUuDvGwF/saCyjdGHVcUomei0IqyVmH66Ddc+/JUP71joFKO8S1qWVD2+qrX8TKJLf7jxlRi83vtXoKncQ0C49G8SODq+BfHUGXiAPVs0GgI6X1hkHkr2BBmt7kONgp1Y5Gxd+mA44pV99ZVczA7dBn7h0U2f44OKjrEnj9xB6KePHJotVaoQlX9oB8BRxM2dOYqFNvyI1+8qbGPByho2DiN3TqkyYKm/NnV/dPuY0ZZlENj+P/3q95fKPBlWk59VaAod8dweQK1u3jWB+w0JU8mHGPcFdYezQP2nIdlkZ0Hh99khv26nATUu/B/6VcnIvcuifOuRK9xS86jMGaX7DFlVok6VWo3e0jzRhC8XpBZApVc6rsTFJaCeSGB5asx+G86/kiAFzPCMMw38uPM4XFTh1d+v+L+JKXcwSRQVuIKV0+5vTygwBS2qOsP9CMBBqsoEkv3pkD6ewpX3ypmOdMMIPHiYSNTnMtPEf9eDpgP6NENiH0smE4Er1wV9I1UCAwEAAQ=="

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
  password = "P@$$w0rd1405!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071231262791"
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
