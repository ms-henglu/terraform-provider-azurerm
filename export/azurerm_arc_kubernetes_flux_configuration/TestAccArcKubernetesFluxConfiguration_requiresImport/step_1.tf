
			
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025056234331"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025056234331"
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
  name                = "acctestpip-230728025056234331"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025056234331"
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
  name                            = "acctestVM-230728025056234331"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3696!"
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
  name                         = "acctest-akcc-230728025056234331"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvSUdLvmfuZ3jzkh9P2/BgRMajCxCNYKD+ZCg/QFqoC1YoOJWqLhnEvLgMrGbR7/7TGeLA1t+NfVv/f6eJMAagA9xzwopYAJqicGauWi80KGglTp0j1I6Qqnfmi+gyK8fNLntoNtU4TfNG2pCKQ4/eFpaqxmWImjcGb17gJCFgEyUWa3/wmhgQMTBnLVHrmuU/bWBQw/4aqb0Dj4LM843axLUp1Z6rO/zJYtCw1p9EuZsRx6cus5rfdW5vtHF9Xz7VTFFctG/gNYbn8lLNFzk3kdEAw61jnDFsF/Mh7fGROZbozCnCuPiLagtvc6E5uTqeypNaJq6X2kLngPqWNbY6jLBTEwcsjxIN3q+95D+7FS2csPWnxsea4JFDKt4eE/e0goLwXHJiZNcA/plOpqoB6cM6meAy4ZvPx3zVEoe98Un/XGzkdjE7aEuqW0R/1xrDiibvY3zCHFeRhRSy/JhCv7pd4mIMWCy17OplR1Odsrk8djj4QEUzZDvL3GwrCHAKE8dEGVVlAm7Gy5eyCUwrjdtff0YDXUjKKqXcdkJag6LUjvTd0m9IgHg5uOQBUDov07/vD+Csot26DjX++ryM53IWDY/0OSMm64KEEmni3T3wXB/axTpF1Z5OmKUIhJ07SGIvjzj3XRgadWRfFDIViFYM3dTZdE81l7bMxxm+QECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3696!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025056234331"
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
  name           = "acctest-kce-230728025056234331"
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
  name       = "acctest-fc-230728025056234331"
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
