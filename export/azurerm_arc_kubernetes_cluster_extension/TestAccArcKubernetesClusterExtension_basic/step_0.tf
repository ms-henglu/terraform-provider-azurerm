

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011130096644"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011130096644"
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
  name                = "acctestpip-230721011130096644"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011130096644"
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
  name                            = "acctestVM-230721011130096644"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2462!"
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
  name                         = "acctest-akcc-230721011130096644"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuMITBweEyJkcVGftCMtTvqwHhvjuPXjUBtTMhr43++8gN66VDPmdOgmuXVNuE3EGzee4ZxY8QAnYNV+MKGWaylHm34G559O/aX5UquEIijo6RtmqxMIxEsPNaypkKxxWn/vIp/AC6QqyOEmsO0yWHWfdoatiOecV2VCHWrBT7bRvV39BvRX/HLM8xBQf9Odez9tVG8ukn3Sm4GZ2J5VE7eWfqEKkBTXrnogTtOFOS4iszBEIeBA1167SSBvly6u2ums4Q9kZhDsVvLga/Af8V0gxfDjcwLgE1OFWHkfH5pK0wVrljlvt+XimFLPC8x+G2NbDj5h7RXJUac8eu+Jlxhuydc2/A9PvjhTj5cO+PzhPx8wI5ZwbDJG9KzUVD4iqlUY6IbgpTxo1U1LsqW6hnOxEVvNoOvE8uej+uJvFKglyySdi0OO1TScRJg9aXPeFi17Be9pLviSlJihimDHYm6V7Oy9oeZrh1SsbgRoJFKFPylIJiqiYi0mgrk4u3DTnHUQ+c83CQXwXKefOsUfuyg/Sdk2v4Vyj6jh7yXtqQPkUCCPirTRby7A4FmQzdR6F5yIm5YVuSOEJXlqNkkVXR4MPRdC4YqWOMqiidddsP05QWeoleny/v/GBot57RE/POe+/EMNMyorSJsURE4+1BM8YY4lESgD0qWyxc/UdhKkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2462!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011130096644"
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
  name           = "acctest-kce-230721011130096644"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
