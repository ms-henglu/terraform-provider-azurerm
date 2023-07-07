

				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003314762147"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707003314762147"
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
  name                = "acctestpip-230707003314762147"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707003314762147"
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
  name                            = "acctestVM-230707003314762147"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7877!"
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
  name                         = "acctest-akcc-230707003314762147"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtw8eFmum34TvfFlXzLzckEDMB+O87K3CuCWO2jXbFisc9VD2vCY4+LDD8WDfDqJ4IExjzjRQqlMoWem5Fk9KPlI7/hyPBkK/2zyVAywsnNISU4ZS7XA0RK4YubY02JhVZ28JX2JGwc8kH5E+XDYwfOw/+uAIP6K7bB250p/txckwEuaGSsSoyIEVCTFUBg1vPU6EdEYD3vrYuSBi2O+3aFVDY6ditzNMraqBO1KFfGov0q2g9rLLjvFpV2I/XrXrvUCVo/RfvExh7sRazTeWPtaZLm8Nb4aAH+LdqmEYoMslW+QNLWMi9yDdpHn6tiQ3nJC/rRIJNWeWYe/wrKEsC81rzz4Q33B9f+b3PCzN2Mny6T9k8naRGJ0sRn7equC09NEotVedEbEfo2i9f3aozXGSm5vtERG7mmKTg1ZPlo8k78/9X0FQq33ag481vgRLpfetSSEZ9HH3iHwz5dyiOPAQ2qnfZ7o2+adv+AvwsodvxHZNAE0p5dMtIDgQaIh9g+f6yDGFBDYgLCHMbrrTXoFhH4/5rrtBpiru5iU3v3fNImQ2+gWlfx3X7nq3Mda6x6/n7/bZyUXdhYG9UOrpMjMwSzRXLs0Q93F38WMrpc/T8w9uWRgTfQQRt8Q4coEeLIfftXFVAPt+TshziBp9VaNdUIRbmlp5gS99vI597CkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7877!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707003314762147"
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
  name           = "acctest-kce-230707003314762147"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
