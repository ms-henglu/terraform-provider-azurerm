
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060615127194"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060615127194"
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
  name                = "acctestpip-230922060615127194"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230922060615127194"
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
  name                            = "acctestVM-230922060615127194"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd7079!"
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
  name                         = "acctest-akcc-230922060615127194"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8ETVZcS+U1MvupMKRXae84uRG9a+0rrPzWlhexy0N3rGPGNW30MdF6fF7F7RKzM7yYO347Bv6IYzfhaw4MDesdruw9pKaeR8/jyI25+MGomCldR1x0Lk/dVGKz6l5xRknSk8AUJbGgm5tpNhrQUmyy0JTKYnk1H5pFG1G/nica0RtJeQqlZBkZN0PBQoD3HzmwTOLwUOkjSm+jovdODzZXX3je2PlU7M36M3vPnltOk9HXSGTk43CscOW3n5RSc5Epqr96NroWFQKCG4ExN40YNZ2OlqcaxgV4O5TxKz7wEg9NK5ApHfiuy7GGTAmAvQIgUbBekX4LJXcx8iZDZwg7oAs8T/tJsDNZpIaKXCLmbV7cM2JBgK8c/o7Ls7CDihgCEuBXxU5AqCjRQkz+sZ74Pes9ISCvur7f7CfdXDEQ/u01L7Fhejij+hvSs/PSr0F+0WHiWLRo/sMmfd1bmv671GfnPAIx9MZGOED0OUZY339A3qW1dAmzX899z/h7YN7wWjGhVODfUHtFWEUL1qwH8RqkAzCeFyraCNDQPq/Qg3Bqw4ru6mOhPS92DDn6E7xN2c0KTfYu3R5HlYTQ35MVd5kSy1LNv0B5jmudpnbRsWZ1mIbbIHMTDQqVam3qFffrWLSyFSTV6QtQW6iiAuCeYgWAQ5tepnl9+N11HHA40CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd7079!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230922060615127194"
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
ZNhq3wKCAQAhVMcJuEpBbo5ri5qsybWYlvkuzs8Nby0Ev6Lsx87H3Qbts/DeDmLQ
ExsO+sceVrIZgDeNylblcmnQx5ZhzO+0r11urRnvc19L7fFaZSXrE82xxxGrPa+m
YVupcY72vJxljIdC2CqyjUf221XTKPlT1G/RvOE5dZurwWyPuhb5VSsJ3tVKojds
1pwY3qPh9+U78n6sh5ZXkZ/DvOsFTIJDDiKvoW1kT2BKy3G9zLVnf4kFg1euufEb
N/lNZ9fYyAVgaA/vMiFctcSk3iZzYkLayRsEQtswvfFH6c/SzdUEN0VgBP0beSyr
/QsA51kYPR70gZSKeHBBxlKOHEvYcdYXAoIBADsBEoRjFr7TyBa5q9SzqVKSZ9dB
/Gz0UAMA6hx7jqZUUQPQqjfl2TD51Qq88CUaY/GYJ5EJKAFrLyebGUyRcpEEGqDk
eJxWH4K8fU7Ie4O3/kb/01FajJ4FQOQqk5F5nL5MUTIaMHGn/zFSijNNBjGLIqN0
TxmjPnBUxpHz1jOwaYeUrg2A6Z3a89A6fZnlw6M9Ap0QfUh5jnxkWenfwOxjksMK
TzcQ/78Jv617dNmcxA5M2JMda8dM5e50+ISy+O8qf/hG5dtY22CLgkiyGLI4QW4f
2hZ7d+CNhSe1M1JZHQXeWtlztaSdzfPOlwZnJzPjdmevijN1GKsKmMSZWwk=
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
  name           = "acctest-kce-230922060615127194"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa230922060615127194"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230922060615127194"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test_queue" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_role_assignment" "test_blob" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-230922060615127194"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    service_principal {
      client_id     = "ARM_CLIENT_ID"
      tenant_id     = "ARM_TENANT_ID"
      client_secret = "ARM_CLIENT_SECRET"
    }
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test,
    azurerm_role_assignment.test_queue,
    azurerm_role_assignment.test_blob
  ]
}
