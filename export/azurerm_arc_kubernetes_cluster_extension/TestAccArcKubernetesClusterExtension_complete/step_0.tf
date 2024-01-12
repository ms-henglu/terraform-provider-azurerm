
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033823618113"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033823618113"
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
  name                = "acctestpip-240112033823618113"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033823618113"
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
  name                            = "acctestVM-240112033823618113"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7183!"
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
  name                         = "acctest-akcc-240112033823618113"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1Ke1wmV1fU8bNa3RmRb2PyjkuYFk2MaVhWw2B9zBvEa2LHPVygyl7ML8XzZhJl6I4XQfuiOuwrYv4lsunQRrJJhQrabnrTU/Gu4surXldggGNE2WMhREVvhN9k4MkpJcUW2LmXLicJLiudSDXknLQNBd6GYiF3Q47tyKh8K4xb1tiels9kS2kLsXP9MvZX1oVTQjApFWB0g2Tpxh3ptxZ3RSKJObUSwgZkIc2WsPyxVHl7US1bRGY8ZEEBkE4I3BEijYZ1BpJhWtjzLtrxvxlapNRFxfPjkSEu81Brp0dLws2t85z0M3QrMj7mG753hZNNVe39VutczQyAVFnNUK5L9fzBSBOfa01NkEGbdZRYuUghydnitsp8xnZ1Re2dby4veM4W60kK+EX+dBGe4MAqvdDsobuLf4iIoSrCAxElnjNccZSMd1c4IWAVtGTqOc6nx9E0jml4eNnUIzOXsH+MtFEiO/UfvpLiBlYPXRkHiGGHjTEbxkhyHFqkyxC2UHbixUKoBJRYshnFfKZxV9tCnNC33LOniPzmY0FWgskHpBKMESgNIOOfzY7NwrkM+yC4yl9cyfhYwFNFEJDg0f2MOiWQzMNJCfXDQWYxhuT9NSAmGMDQDiAVimDFm/QaPnf4KbkwNQUxeTT6RWvKfbWe4BmQwa4K58fk/aI9rph1MCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7183!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033823618113"
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
  name              = "acctest-kce-240112033823618113"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
