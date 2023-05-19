
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074158789046"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230519074158789046"
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
  name                = "acctestpip-230519074158789046"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230519074158789046"
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
  name                            = "acctestVM-230519074158789046"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6744!"
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
  name                         = "acctest-akcc-230519074158789046"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAldAZ+toqlgHctT7VkVu1XGNks9WCXAeMJXhD7G0R/xRhc0dyPFah44URdzuW3nCFz/KRtE5QPoy8qv6IFS4mHoYqgTe8KazusK7VyKJLzgWUmkKiNvsNgSBoaBd0OXDybTidTHt7OqihZW9EjTSyS8QmtHEwROPh29SEnvMjwmBjzoDLyho+QANENtxciJdK//eFXtUuvaFa9ROim0jPikEDU3mr1uMlPsvo2991Qa2AS4GEi14W2/7DCHP9EvbVdHdeTCewLWHl2cLinbuk9mPtDF/XwIzw6TcoNT/2aFgOnUVTSJfYdzywmHQLZuZiIxxOjn0afXDlolZMfHUTZFoDrhVXA0GpWHnw/PHKIAmTEGGpd4pxHxNzZ6+UbjIWWrqVLhxvR2x9aADf6m9rDuEa5AO2MSy/YNo1vWuR/PlTo+ZCUX/g/k7z9Qm/0pDQVoHDtws80TkHtCMTnA89YGEmHAfZ9vPb1i2jlMsV7j0Q4Im8R3RWTiR+Zw1hWfavJK7NNY3wWeglMhNlhR+tn5nU85/y4hpMtM8/+UUj5HrUJK+xgXyOkyB7El9d/Cd3LFEN5Twn6LsgO5A4cPLVrtUbV6nmDVd+Il0xLmJx+dexZZPOmE4c9NBtUTsLEFlT3I9sK6emLFwKvmAoaG7va/8yd5Q2J1jim2gwn3wQhfECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6744!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230519074158789046"
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
  name              = "acctest-kce-230519074158789046"
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
