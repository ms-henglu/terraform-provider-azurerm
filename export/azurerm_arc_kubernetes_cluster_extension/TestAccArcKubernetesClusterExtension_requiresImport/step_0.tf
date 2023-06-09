

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609090822938191"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230609090822938191"
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
  name                = "acctestpip-230609090822938191"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230609090822938191"
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
  name                            = "acctestVM-230609090822938191"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9326!"
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
  name                         = "acctest-akcc-230609090822938191"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1N8JjKmo8eRYH3HWN2IHa4FyVOeAXwxVGL1v45cxd3T5oD8YrN5pUMj+8R3cTPrBpyuVMXyCDdMJ/kOoM46pCLvtBD7X+XuikRyVFe6ssFBEdEnyOS/13fjzM0SA+lRW4ku3YCnu9L+JSBLLv6VPKjEsK+SQjAHLEXnUZHPIWQa0fPDRP0ehZFUcpD+9nMbA8k/IFYbGfv5Gk/qAQTnasNcDrZPFhQ/H1TnRLP3dQCbc7CeyTOeJx8LVHzpEUqebX4B37hnQJjrsmF08wJVINo5K+xKC6oyLwwpAUy/OQIDxXLxPUkX3GLKn6UwKy2X5dK9kxNpCaOXzgFLpdQiPjKNsnaYscZ0YyaOXDfEmdc7TLe2KSoeByyl/irWp6EiSZgZij/z3CRc4aBTvKuGogR9JiBMU5bJLeHC7MOmfYVa1WyisCqj7cxhiCzkkiyKXiWZDNvRi4kTClkiFdwCkZUt1a6za3wCAbzlbbnZN2GTINoyFikZ753hV7VyoM5hvG6BS2Js5GvYjEjG5k+mRZmRUttpx6QnQOESwZ0pR0MfX7Am7jt/eCUNoF/v2x57ZSYVEQ21OgmZzGULuJBxqTKcYaBsnVotrUtdTdPSgRXFdSnu93e0Elr21b3bt2Xq1DspRyVgb2JmdCPChsxTf8gLgCbT/hwT/+M+iQqMveZ8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9326!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230609090822938191"
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
  name           = "acctest-kce-230609090822938191"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
