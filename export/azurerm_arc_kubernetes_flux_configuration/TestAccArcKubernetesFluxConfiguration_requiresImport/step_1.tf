
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053622624292"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053622624292"
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
  name                = "acctestpip-230922053622624292"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053622624292"
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
  name                            = "acctestVM-230922053622624292"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7800!"
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
  name                         = "acctest-akcc-230922053622624292"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqQEnL2igsio4zdNHxcToOb0EOH9FxLJPj5Fkyhj9qS5FWh/K4i3tdu5QG2wWaF7e08ldS0wU716bCrY9GocZtsZrq1NzwJ0dRCD1NJF6XJAa8QuWtY8EWdByKXfGUvx1bVDXLgdzppvqUxlmL7vvZ8PatjVvF6DScSfUmrYjIaKaQPKYDJzex9xLTG+8GL8Sy0rORaGUKkf/lb1z937H+/NvtKhsqXMRaZFw1uBHCHBFOGn2oBwIUJjpYzABWq3zHK7b4TspTEEaZwrDp1U39seGFyg+EFweTzay5KCmeRbgWLJqc1AzkuIcNwCZZPspxceFv2Jb0IZNdp/XaPL+43PGfKB0Hf104OAt72OwEsPvLtuJQ7BD2JXwsba+Iaa5nULleVv3rj7vE3oCpMasfF7osroG2gssajcq09DaN40s4IU7/0eoGeOrD0xYgyNAwHFcaaNPu1sJSo5OSG739+RaPWdkTNvfcyCpGHVBHaZN6JwSHY09yyo9KZoJfyiZh69KcH8Ty30F4iwk3oOW8gcCu6KKW+BEPK5UOpUkTV+LcrjU792o45IltHSeCh3V2wfwL0mZSgupwbBIYLHNvbyeVTZpXtcZDCVLiQ9/3NZ4vG0WpDTX6lPzcanScon5DRiQ1vGVnekqq6DVTOmutMh5jmuXXIrTpvMwAPn/vEcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7800!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053622624292"
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
  name           = "acctest-kce-230922053622624292"
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
  name       = "acctest-fc-230922053622624292"
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
