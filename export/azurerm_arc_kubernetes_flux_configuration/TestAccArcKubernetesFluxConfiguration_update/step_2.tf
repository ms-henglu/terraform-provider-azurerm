
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031805598901"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031805598901"
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
  name                = "acctestpip-230728031805598901"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031805598901"
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
  name                            = "acctestVM-230728031805598901"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd21!"
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
  name                         = "acctest-akcc-230728031805598901"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0xUhj73FLOl9KWQMYO17d4xRCeWKSzAagjD828yxk7jmCsrFd7b0bx0EO4v9hPwR2hMsfOCke0qoG+c//EUjcRevU2k6FYVb2G3zLCf+YhSo8aUV8hc16CfJQe3Sm1Gm6zKrlbkPTUpy6QDp+ITJY1axdOz8qCl1zhs5G89uFgX+TjXrnA577rDmdTkOOXCddCX8AUfWi7FY3ZLZ84PrYyCe9yDTSdcnTQDmiiVNPvYQ362YGOyXREBU8MoycEY3XoG6IQe8MkqjLKPwP5S7kzGMez6Y5j91rg3UEpclOg3oTTW9N0vz8Y/6mxOaz7gdYMsSeJCIlDhUe2/FynBIuM9g10qKGnfBZqocloVVe61UhTbGAnnt/78a7WVJ3o85OD6rchqF1Msz+V9MLRpwVO8OVr1kpV14lPG6nDOrC6SLCrfjxBA0TiSUGdHwT6QYBw5a8aaiMZ4WYi8fARCX7wWSnJaz99sPdpi1Km4Lt8xTGiGiFcG/4Ww4IGhQ55rvd3Nq+5TRPGT5SPaq1TjwCgli7AU8BxRjmv7PcaEE1mHQybBNg0gKdF1OOMc7jIKjvFhVOtgReI7ZePJ4LGcNMUBS8VHbKNMI5bHPfqURAkxK4N06Gcy9T3gHtCkfMbVMimY7nxcjFVuiKkQjx9ShWYgbt+TgFrAqTs8WA21M35cCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd21!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031805598901"
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
  name           = "acctest-kce-230728031805598901"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230728031805598901"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
