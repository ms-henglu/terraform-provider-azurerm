
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045227084060"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230428045227084060"
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
  name                = "acctestpip-230428045227084060"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230428045227084060"
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
  name                            = "acctestVM-230428045227084060"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd82!"
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
  name                         = "acctest-akcc-230428045227084060"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAz+6pSiFOqpQ9xeUVoW3tq1b/p/jdG72c+dbAbbKcYP/O4ed6NX0e6liZEYpO8XHD2pZXP98/m3CDSxRGsegtyILJzMHx3cEXMDIeeN7KovRR0wCXeT0IKrtxwZ496xy6OX8GkHCQq8dvAIy1bOa+8BQgVoECBKVSRs6Nd5ZJtM+ZrROI6o1omMXGmnm9l3dO74IBUTUEqy5SLtk0dy3gbC5u+NYNbmseLLTqQquqSczBA8kSBcDx+cNztfZ3iFST9UPJ5Oz935i14VXRNpG90kk5n49mFi1fiMrukF/E96T0fJJJfrXQp+DvsoeuXtxnP5yFbo0LdLDakzEYeYpl2WfLmhZyRoXpkIN+vODbmcxhGJPKDWKJ8F+jyWRyBYAzR93j3a0xQ6+SrCWrzMb3Kf47GIcZl/A4LFvD6snj6++UdcOD56eMKARdmGhEjTmC9PL0pwIycqhuLTXHEKJLmRtl++EMvk02rS/zdgeSQ133XHXskPxRHs/c9VRmRlnzICGYAi8+QJJFiwG3CBc9EjzHYrPCV8VBhxaBEaGiEKaJghxe9F1HE2euTzJar947MFMb1Nb9X8nwn76xmhvwyuxfYrfogYxBa1IE4SgwJ5PTesCPylQkthJt29yV7eSJVXhEKYjGQz2HLHaG3wf2MaHdifgFbzcwIJN4swvnE8ECAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "TestUpdate"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd82!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230428045227084060"
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
