
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022910413350"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022910413350"
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
  name                = "acctestpip-230915022910413350"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022910413350"
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
  name                            = "acctestVM-230915022910413350"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6116!"
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
  name                         = "acctest-akcc-230915022910413350"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvZZzQ9ANbXnSGXHF+T1sju7X8eEIZILcCnc2s2mlzAkXN4S/RxOZQiwm1oaG4hY1HosRHdRrqSZd1flVIfV9gmG0rMlYbjrylGe3Edx8IjNWK3Obp0RCyyogLJgornv+mZ7yPSpaukWZ2p+EJ79DR7IpJk2DPeGTKH6gUNKUgZVWcXKaI73VBWSTzvUO2dTB2ozn2gz+OrAkugb1MlDoW+w18oPGtfDH2eW5t5g3Vx0xrXqotJyI2Sp5vu/+aQTNEAns9B7xHrOe98qHkWZdntuh6JL3G+q5hgNr0U1AIBBOMkH8V8fGRK4v75LdWmsO+ZvNO64KN/pT5/DmjdTaBo5hj1NiNYHHoNySi5ZTKyTyFyrE9p8NmEgkX8ARCoe5XQPKJojGXCK9X/69ENOJ88A9RaiAQfOCjfyzsKvid4kPHtWTF3O/L6oSRiEShk3Z/55O8vKYdveKqLwAuWuj3N/8/82LiP0zYtOGzqxqwm2s7JvEYonPQ6kHZBMLKJvyBKeSYzWNWi+7Tw/VOJWiMTeQAxBzvRIxIOUUVCNnpDFY8BUJNXGSkOnwkbiqnE1PJkUPrwyki4BHCUce5YEQm+Cg1A6j2lQBjewzFGCMa4rlHWbQHxcswdPuHic2PBANhrgTFWcnZzITMtOQPuUq9u2H2Ajj35/V3iqhUSvFDq8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6116!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022910413350"
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
  name           = "acctest-kce-230915022910413350"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230915022910413350"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  git_repository {
    url             = "https://github.com/Azure/arc-k8s-demo"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
