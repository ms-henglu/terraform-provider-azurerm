
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010015572452"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707010015572452"
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
  name                = "acctestpip-230707010015572452"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707010015572452"
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
  name                            = "acctestVM-230707010015572452"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2826!"
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
  name                         = "acctest-akcc-230707010015572452"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxt+mJ1Vu7F2dnGfVRJ8o9mAaSUmWTrGhkWUkBCRRI9CCH3fezy9YIJ4LPwTeY5Fbq0bmjhCV1J9fq9Gtg4BYq7+8AIEr9BlHbg1msMaJbFGis3YXE0x0O5d1w+Uj4E3Heux8IXLr8ZiHOKbCU07SQmAA5w91ZSg/ehBnOl4bx1EJcishuhXvMq8V1vRKj1RTXySrOTGxhvmHbATh7woSJhtHYItdvUGYE9FIYVKUo6Pn9L6fFy1Fk1qDjGJhc+QNOqQ4T9Qk76gl8ptzDi/iCmMLQphYC32lSRhQ+E/JwV6zgf2MY0spOqaj5FP4J0o4ShvjV+Y4JmBZpSMhR7zX2SaXKhaz56YYRAqh0Qx2Vt3QP2XWKieMzQiL7CI1FK6YE/llT3TINhwD9KyCGMPCCh3Cu3aKjyzSqOEZK1ukChDld9K25CIHwtA88Q4w0ZYIi+onD/fnW3IqOa+n6zQqD8pSQVXACDe5CsVl7NFy/+4J4VIxli4CkOZIzuwSwog3KTlxcC7B6y2LRwsh53Wb86DguAWq0YAmKFusrF4J0K98427mOI0V1O7k6D4WXAE9fkp4VLVvV994tssGKpJdQ+B8u1wGzSRfFvEVMZLDkbAzHePCBxjLx1sT8NHXOmC9wkx7znT3WafwgqQcAbOOJxYV79LbULYZDITUUT3xjxECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2826!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707010015572452"
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
  name           = "acctest-kce-230707010015572452"
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
  name       = "acctest-fc-230707010015572452"
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

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
