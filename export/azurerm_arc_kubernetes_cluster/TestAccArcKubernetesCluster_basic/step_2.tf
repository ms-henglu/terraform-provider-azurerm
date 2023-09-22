
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060555414730"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060555414730"
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
  name                = "acctestpip-230922060555414730"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060555414730"
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
  name                            = "acctestVM-230922060555414730"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6913!"
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
  name                         = "acctest-akcc-230922060555414730"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAnE+/mXaN0YacodpzZng+kZNk50MmAh8GRmddEuHzJqPT0kvox8H7k3pCZu0VRGPIiqnUkajee4AEb1rDalCvFhne4h71JfKTN/MyllHf0+PIVChDgMpaVMnclDtHMaTmaO2KqHI19REOeqBXgLTXxe4DXqs3sfmYUUT8ViS6ktcANZBmSNiM1Yv2tDIzF6+q7dCC/gbmnBRz5t4nwhzZtvHZLbHtynaM5E+hCdxlvqCy1C850YjaghWbgiQUEwylgwxw4d4f2rORRg1I3NjP3h34ZV2T2YKGCOL7s4ksmFr0ER2dlFtoS3+u1MtV5fa1BqNmXRUubZliq/dHUiZ5X/Xx9ET/ryzObTJbnDxIbnwQGnF7iDymFA+tWhoULZLIXYq+JYUkXzXVjxj5gSS4/5ZS4a8JJ0sSU+ocMECmGWZm5+IEJtghsmH/FqVyApz0cOt3CjuAr0okl9YZuZgeM1UbJT6LxG+9j6Bc9tMmKAhB6AMDFu5AyezZFzR1nqrbbuYRyEFs1yPftCdplxINH6wCOfJhMXngoWc+dHD3ZkHCgf31OLnmk1RjXrNlVqyP4s5LCF4BwqgDqr49O/Ge5n1TOGowkFEhX+5mY0f3rLNfp4K0HHB85vu6hZrSPQdLdZdxOX7Vwy/+muWMKzKISjw90x82ioYOaw93MkVR0wUCAwEAAQ=="

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
  password = "P@$$w0rd6913!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060555414730"
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
