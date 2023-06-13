
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071344652290"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230613071344652290"
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
  name                = "acctestpip-230613071344652290"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230613071344652290"
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
  name                            = "acctestVM-230613071344652290"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3578!"
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
  name                         = "acctest-akcc-230613071344652290"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA5CTqr6sjzTfRRt9vrfhukjW7z/PuHJ9P6lpfzIPvvgSEqGFj1kX3Cqyiaa57yqG5o1fTEmXANlcH8144wNFALpz5zpOxkjeq3fshZsO64pypecaa62IRUL+eQ3dBm1U+Zxkp3yGnUlMEoyXECf5m3YDXxXaiZSCkRedjVbDKNpFkSlVVnMe/qGGsOD0GmDN895at3uDJpybtIg8sUlIJwt5Px4slhj2xbnEC88K/TwZWDFdv9U8A9rwz4xfJ7xkzlbpa7gcneQWAwXS+0HO+56oRePYhtB7Bys23gUrN4POhWdHZMi9o5aobHr+65d316OVQViLbvJTqenWxgCK/OfypUQWnFQ+gvToGWOpYz8SgkDiV/cU24xYPnpeX/neWTpl7FPuzKzzFHv8EZDqnRlZ+gaIAB94P9/rzkOaZgNCj+2moUH6EiK//k6ZxwgzdsQnpYKZNRO/+Bw0DPvFvH7DvHrmPncZ3Ixfm0OjGsYMyEGNGF++20D0EDAoeM2HOWPlvQ9AU+l7WRJm2KJZX+AdtFNJQhteotqndN+zizKjvgSForn2VHFJUILzpT4GQ696pHv2bFq32wuLD3ovZYNJFNIeUweGUFDOO+XAwbpOhsanCMaATEChgEEOrt/UwjFRfVNWYw00N/+mPUFsUDVuWoeGUVxITdd3Thkv53xcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3578!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230613071344652290"
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
  name           = "acctest-kce-230613071344652290"
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
  name       = "acctest-fc-230613071344652290"
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
