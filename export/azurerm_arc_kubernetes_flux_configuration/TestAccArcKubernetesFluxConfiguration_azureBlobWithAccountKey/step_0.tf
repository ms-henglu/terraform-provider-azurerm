
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031351294938"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240311031351294938"
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
  name                = "acctestpip-240311031351294938"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240311031351294938"
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
  name                            = "acctestVM-240311031351294938"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2522!"
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
  name                         = "acctest-akcc-240311031351294938"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1nGU0YPK+5euO/yzftn8siMxEK1RxQqKKwvIu2xPuTq8R0EYNrBH9iqueIyRkzDfPjvzJgVhdKf2L+v2OSoeBwvAqXPKBIE9aJy/TJdw3Bexxykc4f9XsdwcipE1PW9p7sj6KALCp6WF69OgYyLMfuuhmuCjj4ihJAz2oczhhBGEZWVY3Llpcl4gFReBsaV6QI8qKGowUqU4Ophvu4jGtU/SvS/mz1dX5JJ8iL7+Xhi4P041wBSyOrmpb2WgTFdcEDxdng/g4Ll03tMyWf6005T3drLcZBoNk/SWGwnuBPJZnoxeIZT7uvT0qJMew0X5+n9As5spbXr2rlDEU0RgnVddGVPSl6tMe93/wFbn80C+HeTMsDKGWZ+IRU5tBqgbDRiyRWylWSDZ9Vf9De5Ick7mZWfsG1rWhRvGc/sBzAflmHxtqzgizeOPXTFeGTiuI1Vpu459TJIvkQOPx3lzMyDV2NEYynSq8h240yeARo6Yg4IGprpqa9/OujpoLExN+n163pd50YJJe0+y44KOngH5s8ugPZ/oFnhy/mW5XRVzycFMvczgv5rDQxp9BnXJW/oQP1yN6GOZEhwPD/2Z00uci4bBElo6ms1cvDfO7o09EnVRBQ0joh/l0mypFwsHE7T0+siuwFd2fGOiYh3NnER3EykI/3qsQoDgSuFaEXsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2522!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240311031351294938"
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
  name           = "acctest-kce-240311031351294938"
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
  name                     = "sa240311031351294938"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240311031351294938"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240311031351294938"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id             = azurerm_storage_container.test.id
    account_key              = azurerm_storage_account.test.primary_access_key
    sync_interval_in_seconds = 800
    timeout_in_seconds       = 800
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
