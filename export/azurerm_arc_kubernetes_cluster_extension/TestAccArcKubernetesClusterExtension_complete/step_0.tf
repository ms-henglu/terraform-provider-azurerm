
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024446637406"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024446637406"
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
  name                = "acctestpip-240119024446637406"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024446637406"
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
  name                            = "acctestVM-240119024446637406"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1585!"
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
  name                         = "acctest-akcc-240119024446637406"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA/BL8n23dvyFC0gqNw77MUwvkissI/aLlB3JFKCs2+vkJApg1gdhGCMTh1cdLKXQe33Iyqlx097pmSnAH9DiAIVMqIdXA0z5Gob8H4jj2KLVpBDfXRXOmg9YF7Ay6DiVQ+lwfu1QkPxcpYHNx+jFB3Liphpx3TWCCnDWZLcE5zM06vTkUfuEW91Lmi2CwTMnEd/AsNlZSHIOICoHBstLMAZs6f41Z4vV37Vshlko+irYfjGKHgVhZT9HBgdPKO1ByjKiDJ1jnAlzhovcEtWUgTvmxRi7e6V9+R2SYBhljqOMag8KIhKxA89B+QjN/ZHHmy/gD7tkWfjXqQOHPqT8TSpmFW3ppT59Xl1ZLz2iFRGlLwFw3lw4K8m/9TlTFejr0PqSsfYh7KTaH2yqG91B1BRopV3HvGRxG83/jC14QqWztRdSXbMAE1HBYTD/JDs78cEasnr/C91tQSLbXgmglIiFaSds/fwATrTsm4JMTMCdHJuSqx43rx2239j9t0vx9jJTre7ZW/rT4devj5Nx18GCtMXRLwE1WpCRxcnhi0a48RhaNRiiK6cKrE7tJORV4v56rwlFAnTnuL5B5WDDfWgK9OIohCoc3mOuH1Z2br7EvWJGacnBakKfAhUfKkQOvhfebtr2+lFdHKuA+tR7x8riF9z4WRP4ONq0cGJDQCz0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1585!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024446637406"
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
  name              = "acctest-kce-240119024446637406"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
  release_train     = "stable"
  version           = "1.6.3"
  release_namespace = "flux-system"

  configuration_protected_settings = {
    "omsagent.secret.key" = "secretKeyValue1"
  }

  configuration_settings = {
    "omsagent.env.clusterName" = "clusterName1"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
