
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003322006623"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003322006623"
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
  name                = "acctestpip-230707003322006623"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003322006623"
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
  name                            = "acctestVM-230707003322006623"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7728!"
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
  name                         = "acctest-akcc-230707003322006623"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxqKO4VCmhkB7c3cMLRlnYxv7wS3gvQQnE7WTrZpvbChVJ/SHXm6oPYgFwypWj+raD7b/b06Pt7bWhXuwKSrc9clzrVzMK+icXElmKpIpHVZWpBw79QJbbjjF/vdBohjMkDvDSbXANMwSyeBgI1q/BJzuba8M9s1FCPd8M0zo8hc6JP29T5WMud5h0FlCmK/W2Ajb3LgVhG6M/1vjfS6YqS+6DaukgIPawK4hM7hLCaunjEKrlT5MW+mcFknURDyVX+gSwx3sAzesGczeJ3Z2Wt9OukTH1/z4LQrvTsfXUhlU0PXku/eMCtcedvrHh2lekkIZHZZxHJPGGLCS2zoasxQ5gIebYRqghl+dRtFJCgTjEMU20/ao2srndX5LEuauNGIiKX/dzF3nggdk2gPbUbWfy+52YygmwT//MoqW1dg437vGj/9gkqYF2VmIrrvZCO1E9n5Uic1Ag+8HDALe1LE277tXJ5BDNlQOqywVfix5jTUL7fmuE/M5nFtqgPMzYnH78sUsitVa0llpjP8huBYJv1w7y2ZSLqfvo8aGUxS9GNpvdVpovkAfbYPN0gTL8l2a6asuwrW0edqkQm5uMavYH0aikQgN3n6cEkVFQhEIRXb5lZ+MUHD8OuK9JrzCCwKxm3jQM9z///evYhUm0rZMvInDXHyPJkjvmJbLNRsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7728!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003322006623"
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
  name              = "acctest-kce-230707003322006623"
  cluster_id        = azurerm_arc_kubernetes_cluster.test.id
  extension_type    = "microsoft.flux"
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
