

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505045837156868"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230505045837156868"
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
  name                = "acctestpip-230505045837156868"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230505045837156868"
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
  name                            = "acctestVM-230505045837156868"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5320!"
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
  name                         = "acctest-akcc-230505045837156868"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAu3VzE1NQtRXJ6AnyZIPRtU/2/bYy7AHmuvH+BJHiiijd4V9SOymtPq2Kc8c1vfmtdayID1MsJFyC8EGZLoS8N8qGzqjHBZc4sLVnDQFXt8qz0MIRL+3E6iwkWjT7+qIq5vdvaEsU6Y32+WOixFkWzKyLDfUZW7YnLjhoDG+ndfadggFnBj7douNV/reOLmUmd2A/UcMbumv6zfYVEHkvyQviXZ8w1H5KnxxMxshlX45UNZ8Ilq5H7GkxSR0jB0/370hiGlFOx2Kt7gtD3SOzfkEdMVISI/gVq4qBjJY34ZQ5jcxE69T/EKvsLgFj+Rmj83WZxdnxzIXHgL/0yytfdyxd80uZLH0EDTiG0b1RV73T30z1aXqR8zX9BxP7oXoowyyIcLe6lQF0Jo5Qy2Ij27WKhFPODqWU2HGwDj1pNV9CNe1ugLcheeLvdJjEhEMqn+3eqDB3STvqFQMfKBMOjAwXIWAjwWmjSUaXzVpvQt7J9nZZo08VzHNNqnrx18VyPOojMKI/1ej4C3kHRgyDWVrTW4eP5HoV8gYj4giaetQw32FqMmP3SKe2RsjHRCMAmYNHhqBR28zJGRkynLlxESfspesp9wNCMACiXaxhhI80UGviYdbCRKt6vbK0zHe6huF/3dgoX0q93tKeS46JtE5MR28axhKQL1loB9zO0qECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5320!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230505045837156868"
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
  name           = "acctest-kce-230505045837156868"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
