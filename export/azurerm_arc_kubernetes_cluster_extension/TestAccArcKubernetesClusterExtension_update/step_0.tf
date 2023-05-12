
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010218426783"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230512010218426783"
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
  name                = "acctestpip-230512010218426783"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230512010218426783"
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
  name                            = "acctestVM-230512010218426783"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1756!"
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
  name                         = "acctest-akcc-230512010218426783"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAoW2e2mgVGV6L/aN8P5cJmk+nP12L/fX5GmAzyKaaA4nLUr0D47lIOYYWZL4XXGTJRumSAExAvj3joxhJhHUOc/jTJ0KSc5ynxP2UfvSyxZRGSfHZSxhlUPZU2JrBXho0P6btE1IYhRf3e+46tvFN88uTQKiHUnA/I4KU3TaadJSeuASITIrDvLjRrAeh8HBVvVuDlU8aWPTDGvqgCsD+7tQ+hg8HGKNu5E1pmjXS8ISlrj1i5finbHNPmrmwvFkSpKuC6haUUD5D/iq6fXlc3B0PYOAfMMgKG4PMWJTcdLum8/jfBKcss+D4q+JOv7yQ+6maoyFZ0I+GCM1th5RixUE4E0pWPVR0f9sn2AbTpcvn/pvRKkxqTmzkKLDovFv48Md6e/8GFABZ2UmorpNHpPI2JYJMgZN+scofV2Fgd8yvI0SJ8M7foAPWiIhngTElLr0Z36EIx3801UbN++1L86A3pNrFw1iFAyApIA1Kn/C1FfKxErIyLEPmkkHoOojDFsHNMigiT3FuMPL3wceacYuL9ma2jxNBReVSnN5IPrqo2VnFPrxRypViYTo6CNQDw1fAIY/YoWM9FM9vHzSWIKn0Rudwg2LPryWTJMlRlnpDXZ4K8hiuVevlhWfr9FSRvuzZu/pF352UaAVFMhSbh9E75kXZZW0qYGwh4MEOXM0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1756!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230512010218426783"
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
  name              = "acctest-kce-230512010218426783"
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
