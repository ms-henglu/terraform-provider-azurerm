
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033825416046"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033825416046"
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
  name                = "acctestpip-240112033825416046"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033825416046"
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
  name                            = "acctestVM-240112033825416046"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4235!"
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
  name                         = "acctest-akcc-240112033825416046"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsv3vjdH0yS9hUz0UzsAALkj72wNUmJ9BkMkxkRkjqb9amEwKytXpW/K3OEF/aaqAW6tqXmx6vULlP1qeV80lbgHbdVSfxoOB8vLR589ID5m5s/wLHpwCIKy7KUQbkFGyx9EQurF/r1C4MrItL2HRhlSlcdj7FR+KQetsglkxgOBPBt2AfOGbr4bqI37dMwk95F2rwkRDsEGcayQJNfpc+z9mPd6RGq9ygIrOlxD/ykyl+dvUVTQNiZdvfygCTmn9y1QhL1A7fYsHhFR8wKodC1Cip4oQTNcSn9t9l87ExfbkDxnZVzbaWLJ0pA/7PQn/G5kvqCWOLaTv0HHbSQmjR+GMgH3nm05PBiwR3/VNbha6GdOl0rYqeCHh2yZKpFDsp2YoSYNNNxqErS9DoUg19a0555eIIbpdiQD0uGX12AjDmAaRhp8uLzZgn0RMpQnODJTYRGMEr97cd+jonw0IJLlWeN0ilDiIsD5VsIFsxklS28gl3BPCkIjl2IVNUf326IsgoXwb+I3rSWR/a8UblG7j43tPwYUo5dwIZzw+UAKIYHk34dW3/GTCGo6Y1mZOpTBeEmG/VibQFwOQ8uxPR+tRK9/XWZKOsJhGi01IxLdeKhZ3QzMBU2k4KYjv6ZmmcooTZWasFctYuC5o9xQ0+X8BLqS7iY6S5cWqMq2VAjsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4235!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033825416046"
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
