
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031346539494"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031346539494"
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
  name                = "acctestpip-240311031346539494"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031346539494"
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
  name                            = "acctestVM-240311031346539494"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7448!"
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
  name                         = "acctest-akcc-240311031346539494"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAsIs9rdxxeIrzAkyu3iq3+bCNe89HaZU1GNeoj+ZN+f5bnKEf8/NdtX/SUGOXkfwIWTQT4CIZEH5fULGxXtEP+FfvkGGbN5XkDukJ1BmoLIBMrNV4ywT/19wkts4ArXU3prF5yWmvCd+Pt6x4BL9jIZG54k/FBHWOR2YkTQajuv0jup0roXObG/JHnTPyeyUCrWbYJsaG2Q1YUNltbrcMtQzSBCWShXtZzcEHdBQ2/qQTXmeS23bG06vyfrXTPJB/DaylbaHpAj4t5dUYMonak/9m3pxdAbBbAYEg2TylXJrNETkME7ytFHS9lNIcRH0JjDZFNPuCD9eTZiF2u/9OFXCFSsLP5LDT7PTLcR7PatRNIdzRjWKxKR9FQM5hdsyrb6Ro8mNXW74fD1ZJeB2nnG1kYE1LwOT2dq3kfIF6wEJxXKm24E+UlyvHoEfqVFCnuSBY6KN4CY3euWkEMFdgvZXjL+eiKe7Aqhu/Th5dV8IGxi7JActdL4NBKPSk283zpVxZNdCX9fikOpRoWhFEvhmiGhkXwUse6XceUZtfj/7byJ8MecFXNG9BElNCaR30kdEd92VKMyTe7pBKWc6yfGBTP3BepgjjwYyfYw9pZ6r4C05+Uc7V7BfuB5UAhZKg5+STL2BXbkA09Xj+ecNdMzKGo9errmlCRprjjRiNJ/0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7448!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031346539494"
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
  name           = "acctest-kce-240311031346539494"
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
  name       = "acctest-fc-240311031346539494"
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
