
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024049307756"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024049307756"
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
  name                = "acctestpip-230825024049307756"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024049307756"
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
  name                            = "acctestVM-230825024049307756"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4059!"
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
  name                         = "acctest-akcc-230825024049307756"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxo5VXZPjeq/ZhNG64E6IDr7EVhBGl9VCWLVfSVG3o9hQk5G9RsmpRXfrhm1pM1aTw7fAAJunqQn4iBQnvv2wAYxsC5Kso8xk+lgQRaQR4b4+y4WEQGAD8bDY46skqjp2n5W2kcQsMkl0AflPZyUONFmyRyPLaGOUE09Z6M2wcePiTuRHT62sZtPIkWmtq5Fsy0jQFcAUh25h8NLJSI0FUBisnZmpgBvovaWElL60VSUeZzl53Lg4szarNTrfrYuHP4h23kJvn2mWgB31Dta1oLP0sIyONeV+w4DXYKLIpwGdX/TfLK0dE60oW+zS5v2e5px7mib/6iQd29h7dPEBViafh1tdc9VieGXXvlvuaVYBh8HxDciuoDlVVsEiyBo+h5nde+3Cj6RuLWpVzIrkYWqptcLwELVrKzt7JwM7GDbL8xZVorvEK2xnG7XajvKRhUWJ7RbrQy+nzZqr48hlmg7nphmsLy96c5MJqMOkCbkMWwGhz7L5VnnzwB/q+4nY59lI5tTUyrxb3G/FaoUKD3H4XVZOxnk4Eh4NwMGdLxY30NtbZOAZwTL8ITJqJws9gpv2Ls1KCgpI/mb6USrBYA5HtsAbwRlkf2a0ZqQpSYNaR0LppDQMJO9FQ1MkajdIj4SAZG3F/LhNDwLtRB0OTtSpACWQpSrDw9/WYcUcUFsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4059!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024049307756"
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
  name           = "acctest-kce-230825024049307756"
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
  name                     = "sa230825024049307756"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230825024049307756"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230825024049307756"
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
