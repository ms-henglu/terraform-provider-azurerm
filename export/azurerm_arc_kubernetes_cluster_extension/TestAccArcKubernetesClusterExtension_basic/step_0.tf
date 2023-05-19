

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074153296572"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230519074153296572"
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
  name                = "acctestpip-230519074153296572"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230519074153296572"
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
  name                            = "acctestVM-230519074153296572"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4074!"
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
  name                         = "acctest-akcc-230519074153296572"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0jGtEHVFLs5IBWtBf7DcAWj7K8riVu5/cdD0ros3N0dASxxeezDb44DGva2QTkV8uuBIIqMJZOvy+6X2O5uciQYvup6k1OmztE7ThImXySFxZnEz4115opfAIoQQPemrmBW2dczmeNp0d50soc0ypF3gsbzKFQ1ouDmKFX2d5iwS+bpxuuK8ZXJrKkkgfgvBiPOUwVKBQn95TlwzVU1rczhe5HqqcrS3oNx75onHGHCEF1W2kBmFaX+N7Z+AmXU0+5hUB6377ICo2Kp1tMWmf/eVP/t4bBPU2PdIicCI//56apV4r2IF93sQY7Ahlu8HA5blbvYAYFDIwUgj4azK65ymtBVZSO3wVrpBFQrAPC3x6139m6YG9Hv1tP+7a9aApJBS0RzWveAWSkcSf6dGA8+zxYhrIGBWY6F7HIrShor7MqNyK6fPabyOdlWUjUHxqyKlVvVZcy4EQ2DpevhpB0RAZkbHFtOaCEMpC3bwi+1SI19V/XZNmVCDfpFAv57XeRWQh1KdjzGv8y3pWKvQ/MFXPT0J0QwFcRelNJaxkukELJbckkVyIIriazcPaaULdUCfkVLDLuelicXBbf9/rNyTsmCG6k+EaVHE5qYyOlgZmHvs5REGgEXoJHvh5TH6clnG40BPvSAO4rq63C2vXqRGwUbgNN1wAMwDQ0z4OIcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4074!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230519074153296572"
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
  name           = "acctest-kce-230519074153296572"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
