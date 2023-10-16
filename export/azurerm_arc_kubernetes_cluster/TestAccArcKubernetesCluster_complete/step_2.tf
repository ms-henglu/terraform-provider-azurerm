
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033353019457"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033353019457"
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
  name                = "acctestpip-231016033353019457"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033353019457"
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
  name                            = "acctestVM-231016033353019457"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd443!"
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
  name                         = "acctest-akcc-231016033353019457"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2R6jgTpJVcP/yMTN6doeVXy362cQoPktlWV3An2jAw75WwR+otz/kuAcnGVyN08y7Iff7smpyuXsUbbid5sRtIoXEroBAf0r3GD0NPPPMffN+yCFRagcQRiFFvLfL6D+JUV+ln3hGIkT8PyRjqzGC34lQEAyO7Pt3iyHwswa1tTb/RGqG279VlgwKaQp7C5FY3gmY7Nt1ms4sRudOmMVObxGz9juKtISrdC56eLmyfMuReNgubf4mwPXiW7KalO/KvMHQEjyVb62lEqEK0MiO1GgX8rCp4hdKYNVrnfVvnMIUo0gD9DFsqf5BBTGqAAVD85zk197EUi9zi/Xj38Ntx/oSkjUIbJ36XaSXjmkFKKJQNHGBhgvX6qby3paR9HGj1v2xGEf7jtg4du0hMg6wlkiyWTaVvRoO8ZbXkHtXK7bxgnJ+gn7fvMmfU/uRZohO74zLDUonvPztDuOLrO/N11LUA+7Mk14vmPFv8wHc1QqbAi3SfB7waY6OrPVDCIt8fX0rsXR2ZzmqfVQI9mTwol+w2G2v0eIugQ5iN47IjVxkFXyacvLgLFEe/AE4+JylH2FsMLBx6CXlTf0UfvsLN83QG+Dnm2iEsTIbx1eJlmG5QJnM86gz2INXGzwD1ZZLkRcP8awi6NvZYLgSZCyHCL0w18Uz/5cF0Icg3OExv8CAwEAAQ=="

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
  password = "P@$$w0rd443!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033353019457"
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
