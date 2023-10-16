
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033349312801"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033349312801"
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
  name                = "acctestpip-231016033349312801"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033349312801"
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
  name                            = "acctestVM-231016033349312801"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6047!"
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
  name                         = "acctest-akcc-231016033349312801"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEApXQdLPEhS1ERYoMbi7e9D1/jX1FhoAnCIDfGN0O3IuyNPrLO4QntvNIyyKyTftOYX6vUYEGO1iiymTNmX1msfuMjqnNgIt5tuHn55tOkk2ZLYJUn2OYmw3KxAcVwOhX5ZgarJauZc0Q44fvd56IjhkGoxmsSSggZZ8r/twAvyW2UWqVdMhyC4mrk8mQ7S0mbYwE03DUFHM6/oa2tsT4X3sGmEpHuKpONlkgdjpdjEqJM0ENNlAQV7zsVNXmnM7wZnXKWZ7UtYFbcuB2g191BK+/LEIXl5uPI4oix1TuRZMiJMSrP/I/Xrmy1mdRYemOwDgIMmS+mQiFYRiFLEQf5b5abPTwZKJYq21/Oy3ONJbu8QQADLjrlNE1ohoIqPscRAhQ8upxZJpw2SHjfAa7IgynvsWUik9KgGkAhMLkD6eW++TeZFaFQOrBYkgCOFl85j0fjuqq5m+W5E4ona+qTzZ3sSk7BCCLtPdmtDsNQow0JTKtvkHgh4vCRn6slnPU5cJuu59AowEPYOUWsT1KjgphYfttQXUIfPIEN5iOIAWldpS3mkTzvBJkJD4KuZ5ARVxm6bDl7cKcW7b9R9gtnlFQWJI7/IWmI5h+a6StMDmmpvvmlHu97J1mHUviy741Pgd38tqX+T3XxA4nSUwIQOj9+1TdKu4I2p1DSaVk5mb8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6047!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033349312801"
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
  name              = "acctest-kce-231016033349312801"
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
