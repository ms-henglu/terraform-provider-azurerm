
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223944058051"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223944058051"
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
  name                = "acctestpip-240112223944058051"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223944058051"
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
  name                            = "acctestVM-240112223944058051"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3012!"
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
  name                         = "acctest-akcc-240112223944058051"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxsu+QSWKCffRAAKJ2J5WxJN5o9xvVBtmtTrhUVr/IF2T8paoPP3wVyBQbxYxoRdxIhcdeY6eWmWJDAfqYVBIBeudI7fLf0kT0YPsaZWX9bj8n5aIX5skZpY52c5pwp09uEKas0qa6pvCowoV40o7TXYD2wEiy/8GGtesTHoOCYPx4jHiGNUqFS39kGTOl5Bkd2jD6G6z9aAW5iy4S4DSZ5t2o5Rr6Rgy7xUmsNb2LqPn7ifF3Zh3+JGBNEleiDGbzcqSMwHgnleVvle85BAJHSB4Qg1kRm65liMRYOuhIQzCoqtpyb9zbP/J5aeTNZE2ufgF0dXz7xYJzEmk66/Xrx2zFT+P4PMs6Y2RbKwQMGflBovScUVfHW06a8taISdffVk6sADEz8G5nwwIfW44h66ePSSd+oaBlFgzr4pmJa7D6rQRSLdW60vAxViWcV6nG4q2BtYPyn9jEEu+4PWotOnhKkYf48evHCxax1DfTtK0RZghXA33FMSBw8wwL2On0k7xf4/iLya+EEkgZkU/VctsFjGTS97aiFA/LqWZ28GTtRfENby4Cbcvu1Z1BHfG8zei9fvGdvM3El6m1HD20R56sDyU97lm4M2DDbUHOyKbjfbGoTftBz7EO0RyFmlgFpDlqNbpQ+rFmFDUKs77y09aDPbPhdqbK3xzMFK5JZMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3012!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223944058051"
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
  name           = "acctest-kce-240112223944058051"
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
  name       = "acctest-fc-240112223944058051"
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
