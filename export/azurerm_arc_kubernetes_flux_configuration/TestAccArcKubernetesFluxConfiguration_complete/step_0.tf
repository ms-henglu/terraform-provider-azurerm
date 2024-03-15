
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122327899911"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240315122327899911"
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
  name                = "acctestpip-240315122327899911"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240315122327899911"
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
  name                            = "acctestVM-240315122327899911"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3559!"
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
  name                         = "acctest-akcc-240315122327899911"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA6Nh3LkKL0DD1dgRXu3S7Nwznq+tTgm/bZhDYzMrNRkR4GVxH3WGHA3EzeBRqVdbiktYEeFUZKdAN6XpwRlaUcv3hyDHNw74B16Lg1/fepNzFTZ0nxppKacBUjg2zjTB4B+urY0Hs25sb9FBuZjKTvtNGLdOOSJWe9fxarIgoyFmTd+iqXsr1dgvtwTkRmtTGcQcwZbYR175LhKYWBHtMiM2xd48CnMNwP+F7u2xbGuSHCZ/6HYn2lG4Z4c13f382d7jLZTG47axU7TidznUEDnwdPewcIjjn9qS6OY5j3cW2wG9rdEAsTszV1EXxfZwauxka36zb2bLomE9FuOMROxjoyrvq0X4KjUjgz54ue9muLvHsLYRHAdyhwE79vQRtu8k/X2/6B+LUfo3rW+nnalqPAAa3kbZcWLupwtRMc7R4I4j0t0R6dUhegGUDXT7D0NqtU0/gSqycve69tm9GUXOza+q6YGqdOtVqSWpCz+P7JzbRzNwKxqQ6mfPa5eRXo6GBycJirdtFW3R+gduWEluFoikM7FyxU1uFq0NyWa/kuN9SI0nZoCERZj0DqfJqgd8bQaMbNFpLhctqJNTewakbMcj99pAV+DnZY44Bod1oE0sGq9jU7NBfF/zAEAouYCJmOpHVVdsnpxBUQjAL9eVdMt1VCBwyrspCLaRKETcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3559!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240315122327899911"
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
  name           = "acctest-kce-240315122327899911"
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
  name       = "acctest-fc-240315122327899911"
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
