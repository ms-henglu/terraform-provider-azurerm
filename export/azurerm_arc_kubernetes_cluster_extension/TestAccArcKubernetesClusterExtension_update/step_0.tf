
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810142936118700"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230810142936118700"
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
  name                = "acctestpip-230810142936118700"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230810142936118700"
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
  name                            = "acctestVM-230810142936118700"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2386!"
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
  name                         = "acctest-akcc-230810142936118700"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA7DqYEqbfhO1IczGO/bkXyiR6eyx6dgtRRrn0kezacAVvhRlZs6PDVHM4jq54kT16G/gbWOAxWtUvt33zt7uqBYrn2Id7jJNC6RWCTDMQxVK4OnGuhI629EHJlg51+XYeATWYgeD2i3vAvUIOF5B6N3ioSdckoQfiaNsZLsEzm90yEWX51e6kQzN0mLbOsGtQ1r1cQSZBlFqHK/2GpB5M6fLqsscTBN+9eTlbFwbcIFTkVY66gc7yArl2s0IwMLkI4g3fWpx1iBYQXGd6kZk7LDhUUmG4Gp7vFFQfqAp7fueUHHvnIeA6N6jVeTrPxl8YXVyqqUnzT4RproHPKZI654o0hoEzKuseyLJ2Qs2RsC091ONojAFKHOjfJL7hio0kfjcDN2r1VPi4+2eTWfnQtyKzu2DNlqe1Os2PBAouL+vFT7Xgax0UkihbmwgZ2iOWS62A7jUoZz7okWa5/kioIdT08nbsvrjE7Owu1cSWYV9/ioV3hTbKzfrurTKkVp1aKLnpHrjuH8trRetNP7SsobXMkO7l6ebN8lSu0cYf62i6NLHajGFAN55WmLtf02EokwL0cSzaeRdHZ6eOgDyWiSnFb8l3km+f4BHeNIg+jFVPfaveAnnmgidMYDqWN43F99APz7QYpNuKhCMSGibJdb8O/B9XSFyooUwPfFbQ9HkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2386!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230810142936118700"
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
  name              = "acctest-kce-230810142936118700"
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
