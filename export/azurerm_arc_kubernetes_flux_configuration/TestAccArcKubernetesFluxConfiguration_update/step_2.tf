
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060608291680"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060608291680"
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
  name                = "acctestpip-230922060608291680"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060608291680"
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
  name                            = "acctestVM-230922060608291680"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2539!"
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
  name                         = "acctest-akcc-230922060608291680"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvLDFeABh5a0m7fbptpEhSlXLf/XGoNGiOauG0EH6HIg+a5C0yOXlRqZjrpXuoLAY3zzqSCjOLtFbSwIiueyOmcwH54+12al6nwIUsxenR7U6y+XmDzzg6cKiBEqcegHmqgaw7nnPV9Ar8DCXwzlG0CZE05WqGTcmDA2ZOz+Je5cdESXfcXBplQpYxQivSKah90EQQ8smx9wNiG4+/lfK23o1jEAhJSNZSYIUjgYAHksGd+0+KecklRRzQ6uKv/1wRaZoJXcs0mKUHVmcZ7OlbuFN/sblx10zlIKyB7v88uUlUCHxu9KAHTQhQk9NiXLcARZiHK/OW5U0ylrVvaMWIX1NggchMlE+ayViTdewftrKNhe5vITO2+qoF7vYTs9zbgVY1K4LYrQm/m3oIewOF1KY5e2XV7w+3++9Pkc+G3XR/08tnAHpy2TE0osVXE6YeONYZF/IyEMz6zJ2OrW3VESvhfWKYXo3eoaCQqX4f94u961B8XU/QlvEgcSHztV9SUVuJAC5vBF32I685/3QK+X6GTNLo1Ozngb6YvYSyFkJqkekqAOgYLBjUJng40cuVPAGIGhtusXuZ32ozyQHKfi8I0Xt7BzZeAZpXcr9TCBHXKK7TlIqaLXeQFrxER6tO7HcxQ4zPFvDNGkViDEueGwrcTslpo5gg97htNAq0U0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2539!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060608291680"
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
  name           = "acctest-kce-230922060608291680"
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
  name       = "acctest-fc-230922060608291680"
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
