
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031326947598"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031326947598"
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
  name                = "acctestpip-240311031326947598"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031326947598"
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
  name                            = "acctestVM-240311031326947598"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4632!"
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
  name                         = "acctest-akcc-240311031326947598"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtoV2H0TZD6FurdrtjNwxmoymLdH7lEUurZIp58cCm0D6lcLsk7BBGV4XqHiq9Jmv2mLafY7NwCQo91KNlPkaZW9Ltv9ovzQkBrndWgxuuxEHQdL0PnJRnbaNcrMarKMc6ms2tpzy6AzEpIStG/ukDQIUP9c8ygrAjUze0CrZybJxrx2xaD2inCCteJ51JcMngEwSoW0jcTTkbhlorNsYlP7eBS4bMihi/55/S/faJIY75crMU+WVVTUUJ+YsFUGrqXYNqxRIYDI/ZF/cQk7TuXrT2r4zG5d5qW7RVNp9qV41VDcXzwBp6QXAQ+yCIRTVTE3eseAIEkhGC1pz4UKi9p1ttFj1cJYt1He7JJVQSifY9P9XJbxK/ALs0bbKMbY7+Xcc4khOKZwbD63AD4QRQZy2LAByxL4e6BtzpUXJ6xCCfeQb/ISiVs7T4J2HpOM0VRWUrB6+CpomDZcZVMHZboaWlJQd1U5G3xx1moXko/OoyicJIx7TMwMyFpjLO0cYiRdMHUd6etgA9fL19F3dBRqY5EoUljmP/xHF5LD/u1KluCwB9XsiVSr4HpOTA6MfyKBglfpQ4AmluyeHTuMefQbxVmpXmkUAebs58sFe7yhmlSXPq9dd29XCNcd3FgL5GXB7+7eH3defcf5vQ4et3uphaBh1Q4qCAtfzMpxYt6ECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4632!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031326947598"
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
