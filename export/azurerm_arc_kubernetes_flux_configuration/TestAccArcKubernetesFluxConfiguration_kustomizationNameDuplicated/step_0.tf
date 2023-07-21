
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014526152365"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014526152365"
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
  name                = "acctestpip-230721014526152365"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014526152365"
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
  name                            = "acctestVM-230721014526152365"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4921!"
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
  name                         = "acctest-akcc-230721014526152365"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvE/KFqw9z3b7zaDPE3Jh3BKqoyski1Czg++GKy/lT24+JoOP06vzQ9wrheSSIFEokMP9nCbT0UqghjATXj+D8Bnc4VdKZguG78C5ioAD+VN4faR0cKY6Pz6hhGI6bYElRFXQriNb+DXp8Tw2LIedI2IRhjYD6NRhgEkn2qCuh4S91T/G7Jw0//9Zbe3y/cpmdQT58rWVzZR+YKlcZaN2W12lOelKlJRX9S5oYzohed18+DaqVPc+k+zPUgA777N0AOLu4p6GYUFzkNmLSUrsG/SND8Qenk+I+rlWh527Ey8qRODcI4uaLqVlkwh6M4vQKgveYZz06a1YuNYYVR3A0T3CNFA19FK568NhJndIhwf2KjloCujeURpCTasy+mE9jJ1VOPQidWdjTskrZDbauDFmhQbWIcIEH+NkZs+h4NwXvRwpqGmdDDEfgPQS5m1ks5VIa5bOYNfoqQkk9i77v3UCskFc1ntvGFjtUHFZAMm1xCji949c/x+O58XFJpxraCUYPSR6RRlG+SCnAdQDncE77a21XA9x1CHoRuEVuxnMJNA1uj9Ak4CeJdExZV5i2VMoKjBR6z7wH85wfUFUwYVvxduK9b5bMPUm2YmGAudtYkBb/JzFwAJ3maeTkQYxsEjo/KEJkpax3CwcoVtxACV7Ywl5RAgp55hVKi3+7V8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4921!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230721014526152365"
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
  name           = "acctest-kce-230721014526152365"
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
  name       = "acctest-fc-230721014526152365"
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
