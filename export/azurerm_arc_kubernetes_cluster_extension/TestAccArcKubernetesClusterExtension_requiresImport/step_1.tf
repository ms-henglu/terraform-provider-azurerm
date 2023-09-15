
			

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022853327616"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022853327616"
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
  name                = "acctestpip-230915022853327616"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022853327616"
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
  name                            = "acctestVM-230915022853327616"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4337!"
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
  name                         = "acctest-akcc-230915022853327616"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqzfB5Vk5FpiFhyFKrYJxViU4ddZc1v25zvNXUZSGAnXFuZtwzyAdumoe+WF1CdNl6RDzjE9DoOKMC6HNRNAKg5cd1MBSZqncFu04i4w0eIEwocNAm+JPMfyOlcrMLqaZ93TkHPhDvN1Pj2pOvUDJrNWXhpNLRwgFUlnzAAIqKmu1T9JRFETovxXlKZExRiw7YBla/iRvuYTdQdtSTXL9PrP16EN35KGXD1+oG2Gl0ICbeT7vnA/iierhNcPYV4kZsZ9jeDL9i/0ZuP3PEDLSVMqBVr/yScB+Yt7KIZ4pLYN4DE4TqRJrLgord8sAm6t/cZ/zoMpkgWjj1diHZn8yniiZEVYytCoHOsiX/BY28IU8SZ98zfTEQBjp+IFLEnKpG+fkzBaEPB8IfiJyNDAG9yPIMMDxuI1/dSuqHsjU+LRuM/kzR7VqhPx4gvkdKqh5Bm5H/gwVRUgzVNkvauFszMi+CgJhsavZP5783dAgnLROE0ldFpWnOPricQmW0gr+W0LZaDd4KM5pxZLcMvrtC4182CEYPiljJDlzjX1goJ+clCmdfiI/rXq29ndNYmdsCKpguYACMiSiGp/+mtqKa77XsuDta1qCYR2gs5132Qm9RQj946m6SjqVN+1OK+apzRyqGDOethb61vfYbke70hyGpI88LzHsfeX5JLI3DicCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4337!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022853327616"
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
  name           = "acctest-kce-230915022853327616"
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
