
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063246430857"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105063246430857"
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
  name                = "acctestpip-240105063246430857"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105063246430857"
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
  name                            = "acctestVM-240105063246430857"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6497!"
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
  name                         = "acctest-akcc-240105063246430857"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApsMjCEhJFXzpE55krSYyhY8GwR+cl6TlLFWDAijrxi2/EbedvlkCJ0PZd2vQj+p5nVAm8NvPkS9ScSpqdCqAh6K3lhwwWVm767A3V6fceet6EbfEzMOwKTK9382ZeG5VvEm3dB7kFNbVqdzB82RMetpUTuQXKCiLYJRRnIIa8VnIVJLjnaMiyqFW06HQyor0Q8pnAfnyTBZ6lr89qXg39ReVSXacj7QC2T9trPUKHm5IDoHiCGURc41shsZF2IksjydGlT/AlEb8fE16F8Xw9wEELVfhLIqAVNTK7QX60svH7aAjb+S8bYCJ5CWUFioY34kpxqxZyrA15kZO+fLqELWR7kNKof/6AqPlY825eaw2TjqY4z+raCjOOv4tZpJK991EYAlzT1C+k1jVrV2uD+ajjg86Azixs6JvL3z4iPAzpEqFEJtmCuaNeE3QeGfYQ+LJE0lZCtR3K4yNqUakR9EdjJYGc/4cFbKMx3a3VWah7wvj0vCJUtj7QvMFw5Y/TopD4TL1BDS6M9RYIjzgitU80fdg6dg7WTi7IXX4mmmSMevgVMBrcbAooKwZbswo/46hGEG93Y2rlclDkEb4XL91S9BKPEn3LajAud+50ALtgtyG05gc1vy+/1rNs8fcS/ulpKAcsTX7QurAcyxng4Wa0FkU6nljy9vd4q+pJJECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6497!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105063246430857"
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
  name           = "acctest-kce-240105063246430857"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "import" {
  name           = azurerm_arc_kubernetes_cluster_extension.test.name
  cluster_id     = azurerm_arc_kubernetes_cluster_extension.test.cluster_id
  extension_type = azurerm_arc_kubernetes_cluster_extension.test.extension_type

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
