
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025059780874"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230728025059780874"
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
  name                = "acctestpip-230728025059780874"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230728025059780874"
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
  name                            = "acctestVM-230728025059780874"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5779!"
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
  name                         = "acctest-akcc-230728025059780874"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAz3h6XvOU6YfUpEExY71MfblSnWhfZlXmdueYHwTznIkQWaaO/VB/UiFVJLwxJdjqaSV/b7Rfr4yA09h7PnhYlsbTj5vVQSMjVhSUFPhO/Enb7dkw637ADRI6GjRSeCQUVtsyovnxY/YaFTgMDC28Hsro4mGQ9s4EbidNv331muphh92A3+t45/n7Ou55WQiZdCveAYhIrL3uAJUeRvO9r6FAyrlfwZc2VxlL7YalP5j1wmjvva/pR9vj7TuA7tmiIhZRgVSeNR83vK6oKNvg37LuGmsXy67MzqyqvmFfIEPGLv2BRXIX/ltOHfYj2Jml8nbKMFKwyimuq000qcQ6KV6Vwl018xQSsPaPETxjZwmqS11hm/I7tNct3Sy1dKvftfQm96LNCjhMwTos0LYtuV05RabiP5UYELjPVKyaFDDNMMZQKDM6t3SnyaS0S24q5uYIWG4zZoN6QDO1EuXcav3i7/sSFhJMU7CQUTZzxll2W67ibjjMmxSnJ3y+cuWxj5Nuo9GU+pbGUn9pdeiOba6dNCuy2/ibO4nxDhqLduzsjZSlS08FaLNz+ONanhMIIUF+f1P9ElmQPnsDIWYBZmOudxeGU3l2z6i1AoOkyw0l4gt91nY8YQH7lIf+ub66tlXhjkf1dmvnL4on32lvRye9L3r92PgtDAQ9TSoLNUUCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5779!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230728025059780874"
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
  name           = "acctest-kce-230728025059780874"
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
  name       = "acctest-fc-230728025059780874"
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
