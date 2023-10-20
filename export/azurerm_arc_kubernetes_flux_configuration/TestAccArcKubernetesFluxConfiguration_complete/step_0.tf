
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040544976297"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231020040544976297"
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
  name                = "acctestpip-231020040544976297"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231020040544976297"
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
  name                            = "acctestVM-231020040544976297"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd3253!"
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
  name                         = "acctest-akcc-231020040544976297"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAz8zh4rsZJSK0kEWnUPdPqqa3Dezb+FI+GG92R4QNDCG77PP2KmEsx3b1tpvpEWVEWSitpd0nXOMYoAaLGV0BgLYxgAG5L7B1hC92pycCntjyB0r8gCm0Sfncvnbq7MOsXdCsd0B0+yLn67MY5tcUiat3Z5fr/WJb6/bwfr6YNmBHE+g9TGIh6Jepqw5UzqSDW7n6gzQ3Ke9jwZ8P9lVBkDj/JBwND/s1Jr3WX3ELoGPrNz2N23ngnMJM/r7GYIVL9h84wnZM78gEw59xT40N112bOBoyVrJW+Li+/w6RYwZ0q/5aVlzKF9XLu2XLri58y8nJ/Wm0gaeI4e6V+sdY5UF6Q5ZsoOXBSXLwfeqVb5/rRgqLUQKuaZmIK8ERnNlsSglbYsk76Q3wBCpsYUWRvwdIK+3YikUexFHRKdo8of9ELCRUoUc/FodhuXfFFI9Cp42MPx28BancrF4fOPmpX+wTx5Z3nSAMDWZB4yrM0QsKeN4YqlDs+vHcTellN9PTXtT+tmuzWMT8A9QgWFw3CQevUT2Ph6aBRn5iYx55ydyOh6MZm4kn0r969B44v/nM5ZY0NROnlXUl+d6CKkU0Ms/ANyt9ZN5fZIOkts2PvWGwMLYG08WZZnEbx7gm9h+wrSld2Me4Eu4JSsVHs2O0+b96QY61yczxhyLJWV4ytmECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd3253!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231020040544976297"
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
  name           = "acctest-kce-231020040544976297"
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
  name       = "acctest-fc-231020040544976297"
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
