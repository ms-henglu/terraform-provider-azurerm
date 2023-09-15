
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022900228988"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022900228988"
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
  name                = "acctestpip-230915022900228988"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022900228988"
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
  name                            = "acctestVM-230915022900228988"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6583!"
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
  name                         = "acctest-akcc-230915022900228988"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA7znVB2WAOaamKTdazQAExv08imIp7HLhOrV2KsBvdgWA7UVFY8eIbn2N+0E5V0K1XQTHuy32VGg/MFt2pFSj/LfXXRZchKV69APoV/2MM5Ea9bjGUJuBBYs/iZ1Ko7rGuUKB/+HLTmhQg4+J/w0HxjhdE+6/IPwQmo3NuzF2NFb2VQefny45OGN4mjo6kiTv7zTULqvEGb5b06SzkN5IPMFFJZIJFiLuEwIr6Y2FkBMn9VK9ZRga/9WuoMGKiSazBd14daasC6NpPn3vJDS+411VLz/F8Px18nFN0nG7DknY4e7ibNYfEDk0Army25txhRBUGE7ZQzCscI1jSU5NVtmt6itBwCs0GDNO6JmiMdIoB8WFdaP2Ad7wqGoDMOsMKSxkuhZtfFvNUJaQoihee3L2WAA8+cv46iHdORN8Qsytu++nRxHDO3lZOVNc6uLuBpo1mNKvRxBgTzFagY/S4zBS/ePbYf9jWZbAPeISaNIyeNnkyMc84Y1Uk3sqPVaJDgNP0QS5tibCBRWFnBG2StKK/+Vgs/EuyvZh1xz9hHJZJVhXw8cc6xaEo+8bMD9gwvepHEphFxIkyo5b6LvphpF6zBEzpYSlvK7XS/za9yAxNt23b5sHT4rgEfB0a9h3Zbn+abv7Ks2MN3EmvXOC3M/WCyoqNBccz2/VaizoxNECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6583!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022900228988"
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
