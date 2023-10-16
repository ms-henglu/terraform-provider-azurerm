
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033401085699"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033401085699"
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
  name                = "acctestpip-231016033401085699"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033401085699"
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
  name                            = "acctestVM-231016033401085699"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2244!"
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
  name                         = "acctest-akcc-231016033401085699"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA58+zXje0gulj0KyUtVBIXzTCAbsohHGwv+aJH/VJnRQiEMwYX8aco3aAUIeg0QacSTSsejCZDsOUI9Ttl/8pd91oZirT4tYWNj40lQE5nhedZqlprhGGb4LVWqVRw7C1ao1eS/oAwS6l+2HRI5kSaMa6Rvnmz5CJjwF2HglqgGKNS1uFoQbB/xsJuJEJ2vqFayFIp6Xyyt6tYFQ1r5+2lss5lppgynvVT6rN2J35LHXUEEB1r3onsDBWsiXtu2dR0LGUFHEXvAvCSMryf03NwgHntUVxPCVQ2aler1HwLkQXSc1cjeGLyzxeQpmPwqjxQpZQFUJr24Va8QnauOQRgn3gMRul7dTvUvfvTjaUpKYNeR/5fuoaDTeUB6iDtqNIYMZvoonn4DLFXhdvJ6oGett1QgwVA6iMQVnwMj8qNuYp4anvD63Sd1+0ar+XF2SAJjwIviXtintSqYBCwe+ocHE5bsMs/dUMMfAvUbsv4za3eltcuhffZxWODnEmJAv3FLArvVkh3XwKPM93oMFed3N9QjN3ZFsBXMqrEcP6il4X9J2Zj2zvwdOOTijmcElrtqBsYYFfZx/mioCUQiqGOGXfkRemK8OLH5fxDDbz2Am2flVityipmga0a4sjnjwhqGlh1kirZOoYJL1Dbenv61IH+jcaEugD6XrB9lJ8kiECAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2244!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033401085699"
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
  name           = "acctest-kce-231016033401085699"
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
  name       = "acctest-fc-231016033401085699"
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
