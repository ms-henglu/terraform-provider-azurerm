
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045223365770"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045223365770"
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
  name                = "acctestpip-230428045223365770"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230428045223365770"
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
  name                            = "acctestVM-230428045223365770"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8248!"
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
  name                         = "acctest-akcc-230428045223365770"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsNhfsE4aLCDvdiiQ13dEp/+Sk1frsn68+9h+CRgkJ0k85Z9jm6Vl0EuipTacCHgSqWCmtymuro5YnJv+YnTnDe2+QgbDj91FR50DOabHSfOrxKF2bfuX/DgvBnQyi7UlArU5r6evyTi0QoS/S4OgjX4kes9Oe37+eUtDy4PvHeC3nU05It6phI6KZBs9Z0M9CBgLwBpAkzr8uACj32iwyRH9qZ1Q1iN8lKd79hrJoqjsXKT+jsLbDkfl1jNjdv/YEEF2BtjN7ZYcPVBPuC8l9X9TY0lLDkfuNzEkrt4kgzV8Qi2ufQ8Df9VkDsITrES7oruaglpeJdx4XYdWbvUMfuCPBUlHkSh60bo72ZsEBBfYoQBy8S85bEtVRqVI5hF+CtpaXlyarQ/PpjqRBVMVdXP/ANwdDjxOc2R0UNgKyHClK+wE1M2KBxvjICjne1kLV1j/RBetx+CfT0ZnKqMrIhplS6Kzk+It9X6bEtGb8nWBr4fUQkNDmp+HMVKvkP8Bw3yjk5mMsbuAzEhMyrDOJfvJXfMHOt0dVwY0O1syKAhI/rRhvgVDtpWSkSfz+PdNH6Pa0qP7yXd0c6cmZn9G8oP1E8dY4jqb++StCqaeOKbIKsaoxajZRNtHOzhN96pcu0tynPofPUuzszwc9dt8X8ubWufnROdDSKZ7cvSUExUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8248!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230428045223365770"
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
