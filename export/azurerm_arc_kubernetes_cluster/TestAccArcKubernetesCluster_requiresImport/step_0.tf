
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407022911581939"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230407022911581939"
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
  name                = "acctestpip-230407022911581939"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230407022911581939"
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
  name                            = "acctestVM-230407022911581939"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2056!"
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
  name                         = "acctest-akcc-230407022911581939"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAq1ym/M0+Q6SGEl4vLDrSOCXMFr31AXF11roe6ay3w1jUnKszNCId0NGZyJ8/mKpyrTMiCRC8/axMCFEm8/lBgO+cEep/hDq2bZNPxeUWbsNFi4USs07wsJ3qR/2XNdaOH9PKMFT8zSjtUuKYmN7mToVIx2iOTAVu+gieSTHKFE/kYcs3cAoMRNjwba1PoeUNPhaDaS3pHjEwIv7dSFu4uyLmWbuLHZDyCjxErE5OIc64lTRC/E79YMel3fq4MEcUz4jBkQCT6T0LwFIqVst160YaaK2f/yH/GMxASc4qOQr4keJyrQQ6awuRI2RekjnwXNnZPmz2dtVuj/vKZWOxvvMlt8ZJ07tI8AafrJ7ViRzuzTxhiPa0Sa8KqHJDlkmre+k2ZwStSYoJhTLnanidoaceSeONVnGwu7bhqWrKCeKImoMxDxJfpYs6N+kfq0JW653CfmnzzHhxjSUQlbF6+guvTxIr0k8osafc8Q6KjDqjmK06+7l23BXQinTqOPVJR4Sph+QhfgTE/pB38qkAkgDSkJUdS7YveStmJUcHDkzJ/SPYsDJINacfZKnk6+w5idahG7m8wbkI3PgYg0ECFDuu8FhjMybGq0v8fEk26Q7mfgaHW5JOsVNzxM5ChlZU+0YYry/BCUzpvY7uy9y1+vxQWzI2aduV1W/ojyrRYecCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2056!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230407022911581939"
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
