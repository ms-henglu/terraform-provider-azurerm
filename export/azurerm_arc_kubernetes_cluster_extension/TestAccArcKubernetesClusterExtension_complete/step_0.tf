
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707005947570794"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707005947570794"
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
  name                = "acctestpip-230707005947570794"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707005947570794"
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
  name                            = "acctestVM-230707005947570794"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8626!"
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
  name                         = "acctest-akcc-230707005947570794"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvrdGIyXgm7xNgfMmxzwlp/51/C9g7oUh/Wv71CXnRBWF8Wz4NQHTnakU/tqhd69ZET8CTxtnj796eS57iYb5ksNaAmophrjYUgjkZCJ/Czap+dSP76XWMpAxDoIx85BH6LUSpUg/7ZNL1M2+Cg3F9E1S+aKZvUODFfPdezY3Qstyw6CbjzTf6MVX88CaqgBe8700IGSZpk3I2sa4zBj1QxU8t1Wf1PXXbonTqW074Wt1YNwPv5nnfy6WyggXQ27SSDF3lZxnWw48mRS43pMX9xsueV6p8h1nir7Q49P0XfUQcx5v87ekbzevDMF0zGVc0Y3pyh/RBXOkc9j1aut522bUgArqeGHWrN/6O4Py+RuJ6yS70b8Q7NRWqF4tmigFnxBZ/aGLcSYrJOC5GX+9jG+EGTb5ExLCqju07+q8Li2W1P9Oh5WfzYlbfjIb0nNRUujk0/SG/v54kiDWz3jK5sY+/w34/B2RfvdkkbTkuvMlQT0RNRJqsWPpfHThdWqtSKWnCcY0jdDekPkIPo5saMCDHt4mNES2ya5vg5EgEIvHUukaPaeaTFn7H0Dea003DWZWdV01u6MdUByv6VLGGaZ7o89Yuc+YPPyeWYZA63wv9jVrxrLmNWoHfrMG9InJUBm2M9xBgboqyJuF53d72o9P9J9qahYm+GeAHbzf27UCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8626!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707005947570794"
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
  name              = "acctest-kce-230707005947570794"
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
