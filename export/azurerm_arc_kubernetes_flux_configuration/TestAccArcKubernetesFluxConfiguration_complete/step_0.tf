
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060245445533"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240105060245445533"
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
  name                = "acctestpip-240105060245445533"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240105060245445533"
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
  name                            = "acctestVM-240105060245445533"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5167!"
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
  name                         = "acctest-akcc-240105060245445533"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqRn3r5UKWsB9jS0to2Mt8w1fUWTn+fvpxLdt2zq2RZTS96RhO2dgJKBypjZuGa21BTQoRKfFB4OHfRdWm3P8z80MrYv4YviYuxhWjXk8xQc0l5mEnJ4ItG6XE0i4LO5o0622mDEWyY6BtdCjuGZB0BWcsk0CwMVej68bFbSMhTD4v20XGzYyaAxk/f+/AootLOkwrDZhQiXGe9XYUaB6FIhja7LZlZJWnIetSwm5ruSoBRM1PK/NVognOjMxkV6omUgfiCEWHj3abD7nqOw86EyS/8jOhDLahdrQZXnPT56pp0lD1YrKq7X/7ul3rS4lCGdv4XiSeAKWQHRZVVgUvXn+z9EepDZ4OVAO2TNj7muuU/RRKm8qOD8LJAH1dpjSP3ftgE6ZQYQkPJx7m/btzElh6oE1sb9wavQVqvzcMgqd9NcA35Pu3+e1j96Cb6erp5rY1ZkvFFF7PazPkIjOPrpE/lPGBQ7quL5TfciDFcJcEkPbdgE1LSk+zXxTGeU3u0dShtTfe4ysIIw9W2m8VL+jPEf+/evtrF498JtjIXjB+3CGxkAzIkgKmQglqINsbCq0f4Up8fUiRq830PjGeqbZwzVgHDzoLWSFTqapNq5P0k59falPPc3EJsxQ52WfVOuLh17YjY7CwL08WwkQaAYrfsERYd0FiCu/dGwcXhsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5167!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240105060245445533"
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
  name           = "acctest-kce-240105060245445533"
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
  name       = "acctest-fc-240105060245445533"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"
  scope      = "cluster"

  git_repository {
    url                      = "https://github.com/Azure/arc-k8s-demo"
    https_user               = "example"
    https_key_base64         = base64encode("example")
    https_ca_cert_base64     = base64encode("example")
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
    reference_type           = "branch"
    reference_value          = "main"
  }

  kustomizations {
    name                       = "kustomization-1"
    path                       = "./test/path"
    timeout_in_seconds         = 800
    sync_interval_in_seconds   = 800
    retry_interval_in_seconds  = 800
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name       = "kustomization-2"
    depends_on = ["kustomization-1"]
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
