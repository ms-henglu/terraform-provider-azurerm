
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}






data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124225240266"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315124225240266"
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

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315124225240266"
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

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240315124225240266"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-240315124225240266"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "TerraformTest01!"
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

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.test.ip_address
    user     = "adminuser"
    password = "TerraformTest01!"
  }

  provisioner "file" {
    content = templatefile("scripts/install_arc.sh.tftpl", {
      resource_group_name = azurerm_resource_group.test.name
      uuid                = "b42a3fb7-e54b-ca3b-14e1-6615052a34b8"
      location            = azurerm_resource_group.test.location
      tenant_id           = data.azurerm_client_config.current.tenant_id
      client_id           = data.azurerm_client_config.current.client_id
      client_secret       = "ARM_CLIENT_SECRET"
      subscription_id     = data.azurerm_client_config.current.subscription_id
    })
    destination = "/home/adminuser/install_arc_agent.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y python-ctypes",
      "sudo sed -i 's/\r$//' /home/adminuser/install_arc_agent.sh",
      "sudo chmod +x /home/adminuser/install_arc_agent.sh",
      "bash /home/adminuser/install_arc_agent.sh",
    ]
  }
}

resource "azurerm_storage_mover" "test" {
  name                = "acctest-ssm-240315124225240266"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}

data "azurerm_hybrid_compute_machine" "test" {
  name                = azurerm_linux_virtual_machine.test.name
  resource_group_name = azurerm_resource_group.test.name
  depends_on = [
    azurerm_storage_mover.test
  ]
}




resource "azurerm_storage_mover_agent" "test" {
  name                     = "acctest-sa-240315124225240266"
  storage_mover_id         = azurerm_storage_mover.test.id
  arc_virtual_machine_id   = data.azurerm_hybrid_compute_machine.test.id
  arc_virtual_machine_uuid = data.azurerm_hybrid_compute_machine.test.vm_uuid
  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}

resource "azurerm_storage_account" "test" {
  name                            = "accsahkvpu"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "test" {
  name                  = "acccontainerhkvpu"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_storage_mover_target_endpoint" "test" {
  name                   = "acctest-smte-240315124225240266"
  storage_mover_id       = azurerm_storage_mover.test.id
  storage_account_id     = azurerm_storage_account.test.id
  storage_container_name = azurerm_storage_container.test.name
}

resource "azurerm_storage_mover_source_endpoint" "test" {
  name             = "acctest-smse-240315124225240266"
  storage_mover_id = azurerm_storage_mover.test.id
  host             = "192.168.0.1"
}

resource "azurerm_storage_mover_project" "test" {
  name             = "acctest-sp-240315124225240266"
  storage_mover_id = azurerm_storage_mover.test.id
}


resource "azurerm_storage_mover_job_definition" "test" {
  name                     = "acctest-sjd-240315124225240266"
  storage_mover_project_id = azurerm_storage_mover_project.test.id
  agent_name               = azurerm_storage_mover_agent.test.name
  copy_mode                = "Additive"
  source_name              = azurerm_storage_mover_source_endpoint.test.name
  source_sub_path          = "/"
  target_name              = azurerm_storage_mover_target_endpoint.test.name
  target_sub_path          = "/"
  description              = "Example Job Definition Description"
}
