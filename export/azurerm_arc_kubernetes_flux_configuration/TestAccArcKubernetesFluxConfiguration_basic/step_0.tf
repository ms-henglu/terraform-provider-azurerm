
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023528611678"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230818023528611678"
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
  name                = "acctestpip-230818023528611678"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230818023528611678"
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
  name                            = "acctestVM-230818023528611678"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2447!"
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
  name                         = "acctest-akcc-230818023528611678"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtgkFjTfBpSJLTTCPqGvnTY9hQdRExSVQE69o2rPId6lJB/x70qiyYtmNbO5U44S35TFb7xdQthKLK2aJK/jzCud29d1t82pC704D0eAWPwp1ddtXOYhHnuiwiKSLtn1tuX/I9ngZGIb+SGMLypJl0HjKj9a5r8sPB19z8IDapqSs9zJdzfOjUQT5vWd3XzqbDF7v3OPoor+TYb7uH0lStdrbae3tmN5APbtGpYr8fYWHLVTb3UoyKJ8ttAla23U39g1i/J8BHw9A8FzCbTOJ0gkUR2oL2iOak0loHNAgjjxVmbBK1/YlBMLPnRR3u42SjL7+q9JdEQOhtmXRGaAYHOTAaupZ0xFZVvrmWKFKbYKS303XBe1JmWftEM5hG1iA5oTam6QvUfhqHa6CLg/g5Ck/i3c0T9k0LYUJXIfzg09VVZXkYsNcu1DWgfgCGwj+UXlypkxtg2fLopjXAa+PJ50WsGdDrZyEeAc7Tq6Ph5iQa3R+MW/6Rvr3sOnxPU2/s4idOqBftSV+DoGzjxyCW1RoQrWsz5aBPv/79MAqJKCV7LU4FlNd9I6hU4H/Wx3zpOh3qXIblZbGmcb0qAVskeeb8W6NKKcnvR90BGIRRbXfQqWK8LvDfzpN/Md8OWSjAzgs0SkRELfbTql6tCPVjHZ8w/Dk5KN/O4E314+6oHkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2447!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230818023528611678"
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
  name           = "acctest-kce-230818023528611678"
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
  name       = "acctest-fc-230818023528611678"
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
