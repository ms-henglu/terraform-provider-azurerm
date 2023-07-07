
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010004949403"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707010004949403"
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
  name                = "acctestpip-230707010004949403"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707010004949403"
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
  name                            = "acctestVM-230707010004949403"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3663!"
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
  name                         = "acctest-akcc-230707010004949403"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4R5Oqu/XxguxjPMDVOeMS7Ax4AUOuUEaW51nagU6GLEFTU2viWHcyNoBUe4kS6bOXbt9QSg7m/40KHJejqGNft1L+bU8zw0VHVJ0ib2Tk/Oi+8HO+JC0TivLdHwbzXJGJNrfLhdQmbd76UtKqsVGjabtPXOnY5fj83FvQudiCxzecgytDVH9kjSFtbCSKme5iVUnD4TPrqQZd9EqSDKn3OUhkGYqIrk6FEk2mFEefnyL5fGRWHs+phZmXrQegfM1AIoWTKsrg7ddFCof7aikxcrUj+r8bFuKYatdM4h0E8921h1nbdLKXIvGDWbhSe2fFbnpiGuElvuu2Iu/AS/sp2zYg5R+4CfCHe0UJuNHoaPJZXrWaY3XiYue92UkJgutkowI5frLoik3sGefXL1SqAQXdL4BjDXLA/9YxGjSBFGrxs/YX853ELt7CgENndzX6foWVLVO16zrALlbOzdcZ+ucavEEkg/mORNGawLNW/8ZvX+pqVcggcsw7BgIYUfvpBji1fFB6sXjHIOTKdCsvwkIDPFhT3YuX9sjgVtM4zFZn+1Hz/5vVNXxqjKzB1WOFFS+1JAf8xnJbuNDQ9nDZdjzYqujUL50hEx+mCZf8y5niIlNp6KIK7troIY7int7HHQ7H1/d8oSqE0COgaiEyualte5mvreP0rTcf6CcsXsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3663!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707010004949403"
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
  name           = "acctest-kce-230707010004949403"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa230707010004949403"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230707010004949403"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230707010004949403"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
