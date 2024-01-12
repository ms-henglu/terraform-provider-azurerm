

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033820418350"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033820418350"
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
  name                = "acctestpip-240112033820418350"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033820418350"
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
  name                            = "acctestVM-240112033820418350"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4167!"
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
  name                         = "acctest-akcc-240112033820418350"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAnf0lLAaUXQowbpLXyNupmf4VCoooeoedfCsyO4K4UrOmKEQZXQ+F+kJlepnx30iV1yn7cTkQoeKlg9AG3sJktZhjxL55AcGNW1IDDZy5D+qGToAdIHf3ExW1bH28d7MpZ6klslYf8JMrpk6KQ+bNQuzj3ywmQ8G7BLbPWsg2GIS1ll4+6305CcrUhEVHIsOrCsHlozgL63aHnai0igPOGMZqz/TPTBHV5Dl85mpNw5f8IMFKQwVEykMUTei+Xm0u6JyApchDKuiPnOSln8NNJUIEGdz30cc6F0HfkWq+k1obnIThT0NpyK20ydWblSPCJXRj8U2uy5l8P1zJMuupHZJ71jBI+dGy2b0+SwAgDAc2CnxawTqMAGFVNAlTqCcI+CFf0gHCKdBtS+HSPnIeO2Jw/UduQ+zhTNcrrHzIHj+4oixtl2e2uR85WVOuHx9FTIhr4sVfYmf31oA1NOgqCS/vIhTCItVxM230FExIOyjjK0YvZ8n0FyxZzAJqxnu2JvHCc5WUNRKJ3sePA0imE/uGmTz5CMON2khWJsDHKD3TbZ5YwY7X9phaPUCB2IK+JG2lulKKPhFISs3K/Fd03hLdIbtucFGWZYsLzTTNTp0ScAzhFcrFs5BR13nN7XBIitrIulYJsDDwIF6zLADxlh/l77JQcH5+i8PuwrB4j9kCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4167!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033820418350"
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
  name           = "acctest-kce-240112033820418350"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
