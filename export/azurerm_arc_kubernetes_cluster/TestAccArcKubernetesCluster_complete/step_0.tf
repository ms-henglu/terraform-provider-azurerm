
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040534022200"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040534022200"
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
  name                = "acctestpip-231020040534022200"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040534022200"
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
  name                            = "acctestVM-231020040534022200"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7882!"
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
  name                         = "acctest-akcc-231020040534022200"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAr2aXHAbJQ+U6hYieF9QH68eQRPQWNQGaTbHOpid2ne4m3hjwWKppeOvgLdVsANzxwYovabisUg6vHvsl3xslQGw5AQU1deqqK1mexd1IaDzTu/jitOf9d7ZNeUJNPmd+NZ9Q/BUMI69L5/+SzT7yKF8FsE8YAVEovP2dHMnPkZfTkto9RyeINTcWENf8AKkIkwwUKIEAEHamNkwJs/dOZetg84KzETRzNk9mycby9JvCHmgiPh624CbP+tCZgzq3GNr6Brz0AxFeVbSRMs/xXRzar0rEaE98Wz2XwCBNsGvA2J4a4vYjIxCR/cfd3o98wEksMX4IIqX7xz2wswh6antcvAA/5TTtUGwFaQymVVrH797G1KSkCQPqHcnJGPnwTRRPBM1SSxG+BuInX0BKs5bdhRQEcz3AZoLpS4WVv0c0HveFtgrvx6Nafn74FfHqSpjQ0SqxpQOHJLb86/bDjjngWXr6PCRUOws5KoNMaCWX3MjkLaVRa/frewTS2fP1RTdWVBlryQXDE7hzM2cW//7nYiE1TToeajfwyTmynPVLcC/TdsrXZ3WCj//PvHIyAq7HQQdkX2jngWDa5hW/zVWbTFRJ1QyPMoiZaTD597Yr2OmqLLVK/Te1exkkp8Tj97dxV8tmVKlEGngQ3/YzA/3A6bn881QaAUxzLVJWesECAwEAAQ=="

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
  password = "P@$$w0rd7882!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040534022200"
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
