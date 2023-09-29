
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064353534390"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064353534390"
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
  name                = "acctestpip-230929064353534390"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064353534390"
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
  name                            = "acctestVM-230929064353534390"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8315!"
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
  name                         = "acctest-akcc-230929064353534390"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5+I5smJA+WbHPuWAwL23b6m3CZAMszIztC4XIniPdcb69xiua6jYoTjKka/x1NG6BA2xkrbnIQS4eCyBe8zItIaKWkfw+eVAsjz5L1x/2fI+wbEqhx+ONqUl/l3KTEWztZj4oQE3KRuUb/PRzBwsAKgY1lHJ2AftL1xMzwRBJdQ3lVDStoHxnp7uJqdz2qNG4Wn47ZDvkyGpcvF16y34RmSbFJW35Xf1c6MTmTYUDhGc/xB9NUUUihxoQaOpk0hGfASLPhINuZxCEGk+OYbdXD6q+L/5M2BnV/D0Pk94AyIkSpraWd4ghtl4he1UyOkhDJVbPNiYNFD/j19SNDhUBu2ieCFN9Jn5qeiVfZbLM30uP3OET5m1QKQuiW019EecJo+4CAsnbZ6rieXxnCvGLYm9f8JyR40V1afhbDmo3MJArDDNLzray9fU5E2zAkjFWen0zKMxXSPdge0D7ZExe12B9AzLQQlz99R5y7sqI3Wx/l5v6zRbBsUW1mr7hzQHUzQa/g50QQqhm6q9ZI16HaXDI78j+ROuTLAYMpkzlsWy+oDm9R17flreP6TuSxqf3RefKxxE+CuMtJ0GjrY/66mQOmQ5gwgZhm61oE8i3bu60YX+oKOEBuCkaa9ub4q3nc18weLcfKBBZndv7dNEQVtEkyqmKHQ0qZjrE8IO1ocCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8315!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064353534390"
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
  name           = "acctest-kce-230929064353534390"
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
  name       = "acctest-fc-230929064353534390"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
