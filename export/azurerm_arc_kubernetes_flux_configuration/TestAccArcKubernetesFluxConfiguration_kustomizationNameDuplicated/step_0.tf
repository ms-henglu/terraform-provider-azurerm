
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040602547656"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040602547656"
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
  name                = "acctestpip-231020040602547656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040602547656"
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
  name                            = "acctestVM-231020040602547656"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2559!"
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
  name                         = "acctest-akcc-231020040602547656"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAwZWEWnaNq7azB7i081Bdd4nZmwEUqwQwEcH6klE+GN0vcKFUFf1lEcbbcCemrHSGTBSYJodMfGSoMCFKcM1Qk4AT4hCzlNogFDHPj2qnSVKKZ8TyoEQ3rTnRRC8J8KP5Nv+5ntPJzrxiq5Po48oXJkSV1XOZ1DdBUGLYTFztpbU9ieJRcgC+/sHxkOaSKSNRgrlv2HlwHt08Ia41gPRGILdJhskbFQGspqusOHhLp4hvVyD7BpoQrfyOn0svAg649Qyk2mqWazYRfowGPsHmHKW+LcsGWh9DWxfVDmFaYgdS6MrpiVemyeCE3VH/hx3GPT4n/AbGXeb+3vn0fkkgExqizXXA4Y7CnxVtv0MD2QuubVsSkv9rKzVzFwdFvCaTuZ6OSriiOV1vOczlTCsQscAhotAqs+YUCNevNqkGRxGzpIyrMp4n6Vkz/6jQeQ/KZAXpeTRf0NSvo4gFrrioRb24Hepug/YSTL/B0aT5+CGMfE6K57xw25HNwtA/zYqJO2l7QJlB9rdJ8Vzb0U5HoCUwNBPP9Ro+7WUO4uKAcXeYOfpnr287ox8UwPZl4xhcOixV3fPGQTpysjUHB/hwgQlajQbejWfqsWgsJVxGTh3dN6jEM4rmSdDJODO9Gof6LzSqizrRRUWjZ6fE6vWEXJfxsQ1dr1AvFPU+yspSqhECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2559!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040602547656"
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
  name           = "acctest-kce-231020040602547656"
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
  name       = "acctest-fc-231020040602547656"
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

  kustomizations {
    name = "kustomization-1"
    path = "./test/path"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
