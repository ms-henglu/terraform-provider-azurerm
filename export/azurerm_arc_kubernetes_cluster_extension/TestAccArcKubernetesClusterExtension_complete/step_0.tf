
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071323907569"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071323907569"
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
  name                = "acctestpip-230613071323907569"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071323907569"
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
  name                            = "acctestVM-230613071323907569"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7497!"
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
  name                         = "acctest-akcc-230613071323907569"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4O0TwZ+reD7rjIExPSremHHI0QjgQCy4jmw1lopaLJG6I5rjxrHJTv0Gq+ZQ3+Whlu4/99m/TV67wRRqRFCuCFQv+9d8Uvewf3fJwb/PCT+ERHnE+34MOJcUJlYrGnwObBBAkboM/aSNOKmEavVsrzOqeyftxS5sByyeFHExCkFvMOfHZiPevn1w334bimhwxzfX2nIhrOFOWeHMmsdkP65mEbZqxaW5rkiVqQpJafVNo5GQJ7OljWEc9pxGqlDX/mRRnI9B53T/DfD2aZoH3zz5d9buw1JqQWL8UhKqVSYswEvAGT5GmtKiJxlmUD6f0iOmhqOkgMoQfwn024KQW4kG6Qo6iJrSOHEjlR+SxaNLRKJ+ludsAUM8CzXE09rSfTL8uYEixg8qnQSFo5FVF5EXo6hYa8sGVMjKsVy26SmEtiyKBR49LVwYQw80PJmaScwwVnB8N1DRe8alaAyCG0oCG4VPyZN5WdtkeCtq4iqdTxW/jYio2e40nb2SdEcM3y10l2f0Ef7USVjl/tC81WngKM4kg7nGC2UPSSHUP4Dtc35oWCyIDItRs9PB7WHXV2gD9W0WXmekKQbsIWiY1S5DpyOVm/k5O6f1fxFb4OEB4utJfilLAOKBTU2XxAk/9KkTWpatglYMtBRarPvmlnFioVNn58klAXCBoEZf94MCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7497!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071323907569"
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
  name              = "acctest-kce-230613071323907569"
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
