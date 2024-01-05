
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060234554241"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060234554241"
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
  name                = "acctestpip-240105060234554241"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060234554241"
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
  name                            = "acctestVM-240105060234554241"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd29!"
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
  name                         = "acctest-akcc-240105060234554241"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAr/SnT3A8vuV2ijI1fAjvmuNPyfrTMxKx7148iB8pfM8sLVHrTi+anY8zucwqEgw8qFESsge0RJu+JtOw8YnNHrWUI0Y58yb0tk85oC8jsj4x4wN1sFKaheedzMrF4HJ0elQWvPD8YuOjPA6K3Io8z97rIGJ3Fai259EpQhijjvYC6f1370HPv9N9x1v/4EhyJTkIYM+BNSrko/n4dAIMNgguer+ACqYyJN8dNriT6Yol1mbZO4XP4BPbx9G6eg4II3pbhjgVjCLtFWoWwUgXuFy6GOecOzsWDnyCfYsNM9cZATvgHw/9th9CuzFHe22z8w99gKSv3TdQP52JzasNLwySydf21tFqJY0PWjpIbXasECCjghpFqwyYyxPJsFA6cj3JqktFHQkruXVtGjXQ9/PkH7JVJEFQkvtgMKht3A/f3xLT4X1zviSBEFfLRtwV0jakiefF6jPF/TAchNCC+aEetYTwhCLenfxO5HdxIpV4C3entWtZP5elBlF4zOOcB7X1yrfIC3vSPQX2xCTYq/MDUuoASrfUxic2aUHF+rgOtB8/PCexW0heR8AKiKRbbqEackphELjfdLc9GHDihO/tc85Hmkpyt5U+CeSoLAH0hoQ8wpAEfNLyLCVCCXys4qgqdNCK2YJKrBPBdatdGMeB84gkGZfBw4Qjm84yFbECAwEAAQ=="

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
  password = "P@$$w0rd29!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060234554241"
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
