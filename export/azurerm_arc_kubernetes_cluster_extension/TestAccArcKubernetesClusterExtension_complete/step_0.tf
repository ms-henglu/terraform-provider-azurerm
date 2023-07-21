
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011134151735"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721011134151735"
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
  name                = "acctestpip-230721011134151735"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721011134151735"
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
  name                            = "acctestVM-230721011134151735"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6730!"
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
  name                         = "acctest-akcc-230721011134151735"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAyb6//IL3gexOqNUCJb7f6xPuYDg3Lba7KfSfkq61PdNk0SAcpwBMe0YHCpUUEoYtS2rQMHT6lVIYXQdpsD91sInv+txzy8K71U9hgE9Ixu/WspGmLp836bpvNYk9mvcYlGpOuO3LTBrBgAMrfChbPQ9PG8szhFd4fkDs3CoaiexLJSiH4swhlN9H7ffX0RerDXnNJk2YMdt1M4ohGPB0N2ZrmXzE17T4NjXBnuOL4MHcSKt3D4Qm7IvJ8PwByhe4IFTTpX3igBYyQk4ObBDTTWgjf8TSUPZj1L7Xre+9hO9pcwxj63BoHegemri9xalE6cm+AKQWOJDQm42V36CLL9IMS+Vf4tTKesrGPtRMkyHbc7H1IPbW7Ng0BvNjYV2xf7xpXT+5YgehECx7dFwyVDrEwrhQPrq2F2DjaGhPHg815bgx825kgYIPFuEEqJRIeZ47ncx06GE5g6fPDw8xkRHMS3P1SE6yZDfaSc5lfysJs1JGh6X8UQIpIjjX+uCpybn0+sKumTJmCUXijMKxsArkGG7YGsRAlpUzz9QEooWRcvybx9pawm1mEUChtUI9ghKTVUjLJbljBSwU4276iLxenHniUnbsSnTFYKNRS/+FWv1NPxIbRaw3F2sEbRvuhzZVRmbZJT440CcXvQAL8VpVQfid+gB4PN7MFI8mD+sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6730!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721011134151735"
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
  name              = "acctest-kce-230721011134151735"
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
