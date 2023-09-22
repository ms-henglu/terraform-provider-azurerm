
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053624705295"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922053624705295"
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
  name                = "acctestpip-230922053624705295"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922053624705295"
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
  name                            = "acctestVM-230922053624705295"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2748!"
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
  name                         = "acctest-akcc-230922053624705295"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA3hoJGe64GS9aUZvm1Iay1qexrmC53sgH2jTSvXPFBlYFGqHYohxBYoNA7qUSJA4lVu2kwc3pBFTCfzMhNaSUE052FPR+8F6yg3CP9s3DgRiJ7NdpWU5GcspkIMhu4Y4xuyrXBxQj3fJfy8tm6cTd0bTFKGljvqgXsnDPr602t/alGe7nqpGT64yrDcHpWaGyuRSZa9aHGPZx34xEnlgoM7nSnjGLmWyTSTypIPXgpcJ2lbcOp6o0oEdzcCOA+mZdu0JcV7ThqrkgGorYzCsAuBf4Y0OxMhJvz1hBK8GscRQw9JsqhBqMWBrS3m5FFzXzSLqwT+kuFTfcDwX3vZ0MNKb1IFGIGkFNhGiOcv7W64JXYiAl1yNtiezCKECzwJVGIoI2Tn6Th8Vk0vwrg7rZIn1X4SPnbQi1o+fiGPdASp/+7U5k9U0PLNoCahPi3r9lAfWreyLlr8X+C+gMvD6hTnHUdE9SzOC2qaxnbewmiqznI5bOFrtOcPudm21bbf+4KRgf2Uk1HtnzKKBFarWrrGloz0M2FDYa/LQ7WuTA0jb38Co4lM+N2AONFaYBa4zVbnJkbrN3JdPzlcnQI6iwjd+zoli/5djTIi5+0NI2JOIgRpJzu9eaCXzWURm04Sc5YLJKdg+Tov6HfAg5LUTsWrmwBZ6P4hQKsCGas98lLNkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2748!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922053624705295"
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
  name           = "acctest-kce-230922053624705295"
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
  name       = "acctest-fc-230922053624705295"
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
