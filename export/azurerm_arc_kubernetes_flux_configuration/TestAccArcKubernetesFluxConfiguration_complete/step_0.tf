
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024045863903"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230825024045863903"
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
  name                = "acctestpip-230825024045863903"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230825024045863903"
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
  name                            = "acctestVM-230825024045863903"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8707!"
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
  name                         = "acctest-akcc-230825024045863903"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxlTolfea1hdt6SIQ74UfV7AuxbN336OP/H7g3rvHr0DFzx4D1Pc67Ji34kSSYlJ41eD7P1Mh9OZlUGFJad+xP4IVuNM8V0fOu8BNjXwQMPI6t13ygS0lLLpkbLz0cOUvr1mgHJPVjfMeT6Xz5G3fNQvalTirbhiwqYj6wuF8qWMpoZslrU1tKZO7E9ZV8/gAUL88N5VA/LbqBgZjKBR27JFGiTEIldwW9ixV86K8USWclmVU+1D3njbf9pWg97/laicTy8BQ0Iwd43FAeuOqAljpV8Aw+T5JsNRQFBkSCU46VP8+zhjFwHNgRPowx/GB3/pIUjNseCkCWvP5Lv4hX1MIOYtXJAEyA6w4EvZ+3ibiZn6Pzy8U3Ktme8Jcwm37+igeLG0JI6YWslHoVMRn/CNKpVirfXwbM5BAZyDtXi6uI0ekA3jtdTRvveNc4VJv3x++0Bby29OJalOPqCpxrtMZ1h3pfsvOZOSL+pAfhH48yOeOeGHBisYGwLAIgaArTkY7EobgfExyZAJM7flNdJrfbnNwhcjq75f77TKgJDy70kHIMSDbNsC5B/IRCvmrM9uPH1WMXTsfIyoORqldE/0BXo2XJn3GsN+RGZr1BKyjFodT65JDF1uR2JfN02y5S5R6O5eYbh24ntvKZBeLjNHp5Vj9HCDzRr3zbJ1LsZcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8707!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230825024045863903"
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
  name           = "acctest-kce-230825024045863903"
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
  name       = "acctest-fc-230825024045863903"
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
