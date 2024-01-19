
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021538789512"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119021538789512"
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
  name                = "acctestpip-240119021538789512"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119021538789512"
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
  name                            = "acctestVM-240119021538789512"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4209!"
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
  name                         = "acctest-akcc-240119021538789512"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA2LuiKkzN/M3N7iz/FYOjwV2yqTH+RdKCXX5kYQ9GyOBMtXR0ZmKr6PqVRIyZg6GmlslUDahdzKZaPLVewSvhAHyT9KBS0isDLdUBPq0+qhWhL1doNWpBDVMCGgPG1TE6QZp7c6dHOPi37WuangvdAiC+5w8UXUM3hPyQGJGAZAAPjsEra2SBW8OKZSspd5TB1ktay4yKWYIw3AbE9gtyoUcOSp0L2WzjUWnp76nDUAzRsrhijB8OcOsLnmhfuybmtUi+m9Pwuhv5FitSkfnP2TzunwDmdMsV5d7pzy/Ay1T6ikr2bAnFcwEE1ULikLqg7qoq+8UNWMzbUoUBI7Bn6IkelCdZcwXTMmB7B6sv+jvUQ5vhY58WLkhLoyA9UoMM+CiarA4tM/XOrnNGiE5YBahefgQbRhwNodT3XBvBsBSElD6c0kE/1ACnGRiv+wwBUUhySQcO1qCBP1TCN/xxIc2BRrxTwBGcS3KD2wUAkAKknddv0+5HCio+0dkRSEG75RxkICATJiy2SrbfDtThVxvUWZyeN/t5K4BYXzu13JaAdL/35V0VPnF0YmjqBRo1/BEwQyBI6EMaCaS5AeUv8fW1AYVQfc5f2EUYmj6/UyQ/zr81IJkk3Z0Dzxb9EgiWj2w0gKLzVeeDnW5EZhnYq3pMocBZSfkoeRoCn1LeJ1sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4209!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119021538789512"
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
  name           = "acctest-kce-240119021538789512"
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
  name       = "acctest-fc-240119021538789512"
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
