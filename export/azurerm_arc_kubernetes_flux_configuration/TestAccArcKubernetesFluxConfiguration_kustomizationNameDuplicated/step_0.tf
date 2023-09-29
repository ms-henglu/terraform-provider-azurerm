
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064408804012"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230929064408804012"
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
  name                = "acctestpip-230929064408804012"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230929064408804012"
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
  name                            = "acctestVM-230929064408804012"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5893!"
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
  name                         = "acctest-akcc-230929064408804012"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA0oLKUp1Y6xQyt6b6jCXedPM/jcflD8GY23ld6zMwcUlMzUSDn5c0gSNC8ngZ4yAop13kP0yxzLf/zWrZ17Fqp2hvxGRIfUHJERDbkMSAHwdavexRneEk0ID5mwYjTi3TrN5C7sNg5fK1S8npLA3cSwpzy9eMa82m8T4LSghPDdgmIqdi27wzMXblLAW1tItCvMS9PRvu9CQ3KkXABIqt6ffOrHxvWQ2b9m9aWDce2VYz4I7S3z9nMnhDv23gly8r/dybwgQwPAPanq0p78u7dDCICuexWVrYZdpbbsPm5SgJ7TGIq6/5rmm3V+CN1TthMYZCBueK151LBMEZT/s4Int+tCU/ZfEuJanq0BFvfRZ4uVQJvl9NGIgKneQrqQti79drpEQEu9gQExnsfRKDQHybH0ylV/FXPp2Na8LBUdyF2EjXzMUGdeU/aZohSEaqfqJlZO3JKf4LIHelkhFe09a3eO2f+7qfEOvhOjW4xJzJg3oZn5da1kxbAAe3FqznhGLYx98m6wzJVJCxnxhgli3/q2fvOzYJUl0aM2xhkicjgMnzxD4huKIibk8Nb94NfbhTS0Q+sJYpZmIwo0bUGoy/be/+9+MrxtUx2WZoPaNJgEMEpn/ETXrW7RD+0/NWF1wPJJkzxZB5lCf67m4iLkMAhswGKFRwhZj7okrkfckCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5893!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230929064408804012"
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
  name           = "acctest-kce-230929064408804012"
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
  name       = "acctest-fc-230929064408804012"
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
