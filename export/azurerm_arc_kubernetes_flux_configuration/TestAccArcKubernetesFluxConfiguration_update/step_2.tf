
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071241868023"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071241868023"
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
  name                = "acctestpip-231218071241868023"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071241868023"
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
  name                            = "acctestVM-231218071241868023"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd9102!"
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
  name                         = "acctest-akcc-231218071241868023"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAmoqPK8Wb3puxkB1PTkfo9nMEgd/1y769alLxRwNdWVYk6nk239nKK/CwGee3dG3WhLzak7mBrH6uRWdgLOM00frKkrxyEm00bSA1qXl/vvveBp1qfXYhgNOwyK49ToPDCnvzMGByEMIf8gLnIEAw3ETk/8aqZBg2EPxseKPcKDzt1KZRJDVJwKRe3V8FEFvfnQ78z7kLm4LrwL5Pe+qx5BWNfnvvHqNcFFisYV25Xp6L7uv5gPZ41Fr2C988j5bU7QCX0PaajcKjIh9dMkc7WqR/j1umwivxdBrYJqZDCakryNFN6HJ8BfpmFjdbooyMiOtBYLuut9uabJelEMhxApbDGPEIEiJjR2Q6gh5ZG596qw5x1aQTaOSRjYYFUIvs0rVFRkxnBckoPdyOvnni7udDAoK577PPEPlTsG/GUhWw2JS+pN4oZynS26l41zqMoR3svIIAAvFYfhnNa80U50+RL4Jl6irmnkPiM8VRnagWvG1VSy5SR55VZHRpAmxcLbx0iWGilTQ8hyviEGIZ1/so9BttJ+hzP4FxLWqD7k24J1WKmRg7JnmzCsbb3DSxCzfTjnKN4LYZzRAN0CzeYu0ZEPfCzT+qQu8Mm9TbZ+qhImcWXrGAd+j1KzeE2cNEPvo4UHSQn6X6ya+LsEdkdcvE2mYemDDykn7dDi0EH0UCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd9102!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071241868023"
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
  name           = "acctest-kce-231218071241868023"
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
  name       = "acctest-fc-231218071241868023"
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
