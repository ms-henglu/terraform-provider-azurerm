
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122305761780"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122305761780"
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
  name                = "acctestpip-240315122305761780"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122305761780"
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
  name                            = "acctestVM-240315122305761780"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6807!"
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
  name                         = "acctest-akcc-240315122305761780"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3PajCWRdDZ9yrm6qm/7wQQOgfpgvEBB0SGDTV0/gO7Ymkf7vVt7QRAsIzTa2eGH2ykaGgkJDHaMYTLSLj76IDamw+exF2UVln1gdwlpIfOgv3Pari6+J7Y3eWBwZ2vcIBuQ7/o2ILCu+ppeqFkv1l9agdgziJOpAz+LB44DquOenCMSc2cHaTd9OoNYi5oafcUtlQr9M4FCToI0sudRljabJWODimcz34M5zsymZnHGsUvAtILTeL5MdaQmp5h13wMzRdHuLFs5I8Ja58A5ca57DuWFzZa0HmZht2VqIunOhgrOu7cS7lcP7H9ApCMPt20GLIorKMzKsunq6VJeZjFIJNT9nJ1d3f7rHHBrYqjTr1rp8xQyMxJB15aqif8e/MbYXQubD5T/krZJniq3IN6MxUOMZTrJKvDVtI9bsB98hbHFsB0hTt2aDj1pmP06Q2APFVTQR0q7A89qZwRGxI2POjWfynb86Yl2+kGsxvsNJZKJ511kQr2E8WDgXMYFjsNavvqeuEyR0bjuZqPN+QedWJVn9mkNEXTRwCGzipFSsOaRY2IPB+XtgXgrekvZxAFzY9/2J2WqRGPydup+lTsP2yY8Hvw1/ddi/GdtkOUlyKQRLez9I4KE7qGgsYYx9q9LUmvTYK+imanNUVqxbBaXnx2DE6pWvc8OneB+HOdsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6807!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122305761780"
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
  name              = "acctest-kce-240315122305761780"
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
