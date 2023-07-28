
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025034291971"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025034291971"
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
  name                = "acctestpip-230728025034291971"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025034291971"
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
  name                            = "acctestVM-230728025034291971"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd778!"
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
  name                         = "acctest-akcc-230728025034291971"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAnS8WfgA6EBaSN7qYsWZ8V2SJdNUdEuPZmGAxX9CqQznWnR1rxZ+sVfH+LU98m0e7fgJo9YfdWOOhKwtWNHLqrfuC1zvglv8GThjTEAZdSDuEmwJZMjbGibnP/OlbS+cFJTdHSH2DI4gN9ad+hoCU+cxLEdoGto8igwR4dYX3nVi8e7RSKpOGcZT4mMq0pdiqP/2QDFAv9PWzBRSmIXrG/BPDl8ykdUYSykWHT1ntC8ynnb0TySt0Z/4/EjydudWAC/4YaMbtBdaBFDeKI7N09pHszhq0zxZ0wOceVQxAgWtzKvxB1ODlmKDkzNkiqIVCMlTRoyShs9u+kXlQoOIGD4JoEkzRG7VFSD+mDp6EG4gc256FrN8nrcsCL3KCg+Be0hD0eSbIR13rtJArAicwkI2Kt8+gOoUeTzKDymWCxodjXZuvI4hWuQoAwpyJLKBarGcdq61vO9AqXlf9Yf+zqhZJpK2pU4x26HyD+rs6Tq3C1PIrw4k6Rxi57znsHGxmKncRF+XzJ+dtgDPzG8JkFILTgvWJyXYtp93/el/guLvRT2hulwgikzpw34OTZVmNUmI0ccxzAzaRdrPOucyLfGs225ErM9G8/dpHSzthwcC6Nhuqf3aVkZDY/0KJ9cK2pdore6VaEwSNBYRGwRsJUCPDFLbHrRdmufXS3pysxxECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd778!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025034291971"
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
  name              = "acctest-kce-230728025034291971"
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
