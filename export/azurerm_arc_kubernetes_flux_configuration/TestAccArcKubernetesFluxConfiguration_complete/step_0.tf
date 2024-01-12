
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033837662293"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033837662293"
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
  name                = "acctestpip-240112033837662293"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033837662293"
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
  name                            = "acctestVM-240112033837662293"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8882!"
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
  name                         = "acctest-akcc-240112033837662293"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtLmMhWW2IEogAvLKkwVWZ5mCsAQTv6RtH38SVJUUMh+b5rVyeMfZUGA7P9J0fTDnGYHYOh8i0V7jxLIHBpzakaW55I2fT94kbrCrBythP1Vlo/UU3an/TupLq1eYlvfocNNVttKxcuvb2p0LZCRqrG/18KN2Qr9Jenp3H90nE5U6wT0Eoyg3niiXYcIwXXwh/KZwMKMmhk/b7MTFoMnHiMCDcUZvQ3CJpew9ykEL7hqf5iZd34LFCxRkoMG0ejEBJtuePxU/vITVRYhnBSX9Mu13fGYRZFyOPNmM2gQ7wA5vLJ1L6omIAc1tnJFYElkQABr7W4z9kXfeiKH7x3HrJ5TcQ+P2TeP+BccXCVhcmxhlCgC0B/J+xhoioXqSC/sZbhUVWkBIpC1awWvtDisTr8YsEVUz0KQF6bqvDH0BRxFn6gv76y0hw47wT72bZDiYMcgArFlyphPLyivFjvixejI4Z42ajaPsF1WiKdkD8ezs7PG5vL7q8puxoyvSfAg+9Gil+Fs8zEfU2NKQV5Dp1Iv52oz12olMLE/17Jx35Gw6G53Zon6G8Luw73ak6cWbAJJcEYJsW049HlBEBycc2qylwiMihmVOP0TWfwAdhNR24Zrz2hHGn7bIO62CrdQTMiMMwpwQ1PtEVufr3dmI2VdxOf/ow8+9BbyImgNb7o8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8882!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033837662293"
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
  name           = "acctest-kce-240112033837662293"
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
  name       = "acctest-fc-240112033837662293"
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
