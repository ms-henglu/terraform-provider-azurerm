
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013042922131688"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231013042922131688"
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
  name                = "acctestpip-231013042922131688"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013042922131688"
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
  name                            = "acctestVM-231013042922131688"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6562!"
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
  name                         = "acctest-akcc-231013042922131688"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtF0egpMB0CU5s5nJ3pGSRF8pkxBxjgoj/6Wi4zG5IeLtqphVPK4FJsCvu2AjI7inqlPRIIOFUeXFoZ6+mcwgo8TyqPmGP3OQMsBgmJqCxLxPW79IZ7EuoliqbZKBsVxWNW1EgB5sJJr8YlY56p9wXdKxpGo6vHgE8KlNk16/0qCUKGiCg8sT3MIbHNnyPu6kWJasHfXLpRNX8egdvc+VOYNSDg58ka4dK6Y1DDKPrRLsM+TJC+VAeo9rqd0jf0nXCXFq9AJAqg8jXYfylY1+G6EYILsv0uXTUxgXXhiei52goFgEXRKwjWqDT0Mh81tFpzUXi+zGvzFPPB9Y26iluKG6V2gi6b14pmWhcxIBZVaRn2RJ72NQXAqE27RmWG6v0mJ1OOWSHVa9+ogDwqstiXsymzwP5bC4N1UNCTVjJM74UJqCWWtp3MQkIzBsMEqfJhN/wMxtdcMVVt2TlUJf8LAD1uBC6EvANZWvqEdhhssgH04wmjWMkKAKFV7J3p2wSmlxT1Zj4eKtGMp+jI07j0LXzDZEBN93ReKw7aAtakV1pko7qmNBXyTNMu/CL35zqF5F8XOa1SN2I3aEnO5QkznVa5cjMGceAF71CqNSpoHtOII2jDHOxEw13x8+6qedqTYkZ2O2/cLIVpRPQb/TSrxvVJl27irfti+YERgp5DsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6562!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231013042922131688"
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
  name           = "acctest-kce-231013042922131688"
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
  name       = "acctest-fc-231013042922131688"
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


resource "azurerm_arc_kubernetes_flux_configuration" "import" {
  name       = azurerm_arc_kubernetes_flux_configuration.test.name
  cluster_id = azurerm_arc_kubernetes_flux_configuration.test.cluster_id
  namespace  = azurerm_arc_kubernetes_flux_configuration.test.namespace

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
