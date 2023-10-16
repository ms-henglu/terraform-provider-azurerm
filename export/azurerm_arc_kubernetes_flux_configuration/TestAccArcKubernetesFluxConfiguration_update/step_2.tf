
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033402907872"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033402907872"
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
  name                = "acctestpip-231016033402907872"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033402907872"
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
  name                            = "acctestVM-231016033402907872"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1841!"
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
  name                         = "acctest-akcc-231016033402907872"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8ylStmt75l+0c1RTgvJXIApnR0Jm02wVZ6bX6MaxrcjmQg3h7CM55/pW9EaDZ+34fVs95Hz3AF5/3NfV+tEQ75IdyOSYhTFIPDgoOllkGyP3BnGSm8jOrsVlVYPaLFapMJes7IwUBznSvLQ3pOnjUfjfcaT8VR6bS5Ttvzzi0xfUgtmTNyRvWeAYuxFm5YsAmY7FJM2L5LSVUfcNi3Udg/PtRED1JoUlWAsPUjxQe6ooG4l0NPFsdUc8hTY4AsRo0h6MLevTvh785cSx7Aw0B7TQIvw1Sa8wtc9Xs4OEJbhALrrQpZPfz+Bo3JZWTQHBsBzG2q3ikP5f//S99wdG5m17DjqVqBnMHoyx4ODRueXy5aPGzCsrT5plnoNtI6VO/Aj5YpCIQl5vKDa5zH/4sxcNH3QXtqUaUxmj3cXyMeD1ZKfbneWXCihSPk7X/lr0Af4I6AkN+303h8vRW/ftAIUS7llJDvYENdOS1JKKz4sBdyZbK9SQXUsAGLuPB/FHWoZsAYH0tl3oDgjZP/EGxmOZDIeIzYbfySqNDi1rbAKJv+7tCi+FwfYJKf+UmxKNi9vNDe0Kw1F2KWcuI6eQ/5Zr6Uh/w+8If2UKxL3Kusr8Q2D5Vz5bWh41pVcQ0dPST4eNi/X/eNsd+jCXoH+7eSDtt4djvLmte6MUfJZYEaMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1841!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033402907872"
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
  name           = "acctest-kce-231016033402907872"
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
  name       = "acctest-fc-231016033402907872"
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
