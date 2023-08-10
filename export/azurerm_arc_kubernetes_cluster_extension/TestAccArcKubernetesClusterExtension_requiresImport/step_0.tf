

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142929109628"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142929109628"
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
  name                = "acctestpip-230810142929109628"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142929109628"
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
  name                            = "acctestVM-230810142929109628"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5058!"
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
  name                         = "acctest-akcc-230810142929109628"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtlNExJVfMN5J75sbmxVp4auq3rT+YPP22vqxFdPDZ3fU35//qmhP0O+StKfxZPr/ddhFTUDennV0fj95ZLhC1QwQaan72mTNC+J4WzIRZg5MaXDCod5O8xEfXf8mToU1npSz1Y2cRf4QQtW1DwMGQO4MQ9DEH4O2MiMHBjbbsxhB83a0BXw/W684upXBmPQTZVA+DrAl7f4PUaSFqbBL0JQlsMRYS8kSt9duhAwj4k4MaYlPrN7rvOxXSVFTFacIIlFipgBx6DprXdkqawDOnYvVK9ZFVgm/I/t7SXeWkhn20srdopvmoypUH25dZW+g8A2PkkdvOoDAVity2q14JSr1N3bKtABXjFXnNrMtPJqTJNxLn4kNE0qmVdn86MNaCnc70Hs1sSC94ipzJbKrFnRyMJ8JAbeHrv/bRanQ2uvXwixMLaSoXQot9Ue2UjAayYBHp14qHi3RLOMarfBQw4RkUXW1URG+lnPwsTSfsySQ8D4CNw4pkoc41R318oTTuUJr8ivhOG3AZG5YPbOn0mE6CKddlCpN9JIAzc8ABau77lW3dXlfR+OvxfEV2bb4Nn5S+XEYbCsZx8osaZwjexx8441RpUZ8qDdVm75KOHHzfzg5N7sDzdXGjz07Djs//WWxd5SuaKG764Rk2vrQdYPoR3KRshxi68bliITLZP0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5058!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142929109628"
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
  name           = "acctest-kce-230810142929109628"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
