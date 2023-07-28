
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031743503615"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728031743503615"
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
  name                = "acctestpip-230728031743503615"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728031743503615"
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
  name                            = "acctestVM-230728031743503615"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd86!"
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
  name                         = "acctest-akcc-230728031743503615"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAu70kXuQARZbqXGkswcmgzEKg/I2D2ceuetjjmfg/gkHEwmBV2JA26TiCmy7RqKOwx4iWxDLZd2HHarb2CnVJvcaWFvKLJpi1A55172HHvbVTaZsc3ipe1eJc0zkVMjh+fSKzhjM3wYX7Z4x31vwPAr2JbDCcd5RMquM18cT7wpL51eu6vq62CeBRyeZMUfCOXQsUYL6LsRXkZ+ok+VGCLERBqBltfCOSWomzMa00M6YdgOwI6UPOGYPl1oteEwdyeGII9S594ZbBOieWCm+iC+tcNl1XtVIFkk4Zm3kiIdA7+FtLXoSU/J71vpQS7mX+hNDdJ8mNeZHnvRooH2wPPM0VO75aiPgYar2xpceDtQC49z8pxw1ju9vEZLHUIA16nLS3qEO3QVJzj5r+cMmlOy2v5VOiRpb4MVa5im2QOhNYHW8FpZ3feYnrnQ38g4aoRHUoRP1DQtYKhZnpzF7eZoJPXaIkwR5ZTcZyEoF8na+Qdm7Fd+ymnCz1M8LPXd/QjATR/5dChM9D94mW3CizUaPsroaTfOILmJTkf1CdcMiuTDokta0wlx5oMjfCOwrkG/3nnn+8LSsdm35bCSqGSKJkJbsRX9sb/N+2a0zu2EnhELC4cKEK91et9MgLOevhgajRgTQdVyX0BKtRR+VljHPCdc3crTcWIFfCT3imNs0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd86!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728031743503615"
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
  name              = "acctest-kce-230728031743503615"
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
