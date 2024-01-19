

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024445448808"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024445448808"
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
  name                = "acctestpip-240119024445448808"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024445448808"
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
  name                            = "acctestVM-240119024445448808"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9936!"
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
  name                         = "acctest-akcc-240119024445448808"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEArS41bhQxjfZ/mAi8Z/Eh/oSs4z822H4F2x9f0jbS4zBLebGsIapl6XYpttmyUZutvRPlWZLc9c6p1IxCOim7tNEi4HiQOGfxQd25FIFxNNSABd8KciAd6BmTEg/KiHtd7TLz9xCQnfp5Ay3R5gpnUMmVNy8EwhjBSoc+HzlYcwMLzVFHJvO+baB2tm4VKc26iMw47Z6tfZ/XI4gvYXW0ZG3sfHAV09itLgsAJC/Z88XKuAICJJ03iHWXxGZt9Zr01ZfUXjY2akiPPLUF+bGCxPp2wzTYE/EpQVreImEOVdOzbgQgFzmKYcWkdw+0ag4JaawCDfJjJaiLHjKSxqogGeR4/MCW6qcQjREEqdHGJFR6yEcYIqiBhKRv3/llO9NlBmQa2pDlFqG/z+LsZeBI94BGf+1p639cJFg4CbtIvrQoqxSy3ZCOtZAZ46uVRcmMk5bqhgkOdHZEbvkLBgxofqPySZuhBMmiV97gO69Xu2U5Nooj1RxSPOGrQFn0X1HShell19eLl13V4Fg6IIs4m8M5wHMust4PPb5mr/Ij3Ee4Qzyn2vS22/T2GGB0EiO6CA75A9aJJAbrvGIqP8soiiSFEWBvCRkGqT9KcwMRiEJCo0+IycF5M4t8N0uSqml6babZ24snnZDyWKUs3eMMHKeJQkv9J45Z4eCy+nyWaKUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9936!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024445448808"
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
  name           = "acctest-kce-240119024445448808"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
