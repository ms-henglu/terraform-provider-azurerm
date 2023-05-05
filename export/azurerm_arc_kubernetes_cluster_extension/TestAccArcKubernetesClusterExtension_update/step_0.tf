
			
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505045847192966"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230505045847192966"
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
  name                = "acctestpip-230505045847192966"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230505045847192966"
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
  name                            = "acctestVM-230505045847192966"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5439!"
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
  name                         = "acctest-akcc-230505045847192966"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAx4ZegAZgkJON+VR3MaWFl9KteUaVT2KT+oI7yRnqjmO7bcLSIb1U+JYIu9UtrNe9iElGm/3K1g13oaWu1vlpF0DJG7xLpjyo37SOMz64/7Kponxfv0mXCJrNQ69SSkmHVbMZyYlf6UuVPtnIvDa9E98u5V4clm947MWqGZCQtymalOikQdQEWndxyZu5yIOPg5m8rMW8xRD3d6ou5RCu6x/AVg5SGTbMcSEbwEUG88NVebGhgQ6Q7F6Xa+fi1qhcjNIvKu68XkI+42PaekOo+m4PfP54i3dGETNxxXAX2yveTaShaxpiaNt2TjqzlrF5omaolSDkLYUFFWvztd0Lsncb6bwNbMm4cqnvFfxVi/PiKK7ybP3kg69MnocOKxJCNGKmf25bhNlWtN5rHbGTDXyJu2r2T6c0FjUA8MqL2qyAjVf4rYz6B7ywx+y/2vdqbpqeRF7FhI7pd0Koda1nRoA7XyOIXArSDUDxwa90p4Mt1vk7EoZVyr7lKyIcLqza5P4wbliPY3qpEgUNUfgjfkHmCE0MMMCwGGRCcmcmRud4OTi3yr+7cKUUy/BouCMYG6vvRF0MRJz15y4QmNwXORQoGx7FYyCwHQ5Eb2argb326Ffbrsw0OZCO9MLg3azO1eDa2nZwx0Z2QaGvb4JshCiT/ZdoqBCMWXN2tErhu4cCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5439!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230505045847192966"
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
  name              = "acctest-kce-230505045847192966"
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
