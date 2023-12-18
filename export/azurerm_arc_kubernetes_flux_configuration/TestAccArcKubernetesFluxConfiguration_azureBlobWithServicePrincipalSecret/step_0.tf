
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071249879270"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231218071249879270"
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
  name                = "acctestpip-231218071249879270"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231218071249879270"
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
  name                            = "acctestVM-231218071249879270"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5059!"
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
  name                         = "acctest-akcc-231218071249879270"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtucO44+/JiJ/jrUQrgTu03RxUWsQF65WUINzvek2UvXCcc+U7q11gjvy/IoV9fOJ97ZtdyVP2wdKjNuGMuK8F6wSLgNe7WWfy248LbxShbpqcVF5MYs7zEOZR+6vQXjyfQL3uR8/eQCvAFZ5avSbjNN2jHPLkwedYLL27l6g3bAOredzlOOE8rjzbBtNxPgF3lFIfhQIGXzyhnUxVWDgUwL4fIpsce8ksJUc02NEkc4Gt9bCGbtwBSy6P1iccMcqWFQYq4MO478vwrzZ5+ze6ac/MPRJLDimLZqKZUuTdDetSUR9Wrf2wQLI/JdC1SchzSOWWKJzltBdSW09y2NNSrfLlk4ChiRlaHxukaeDaeeWFIgRktSiuqa80vZ9AuSInacafAlem3h2jvjDQIY3od1tbJ65EHhbdEL2ppf50v4y0y+beP5R1q4vPPWtFzNmHdSlt1VUCaoTOWtXFZSFOx0zVYBCu8cM30VRRDUgbJ0sZoGN+nDlzlug0RrvId2Yr9j3VG8EHLZiB6gftyjUWyuBO2doJgHF1EqGBLGvfVeA7w7aqy5EJFSu07gOwHFCOB9COALG+imOV0aFlADzy2q9G+5cko5iuo5qlBfYk4Rzq0urmAidyWTYPY7xbHha2xIv+Ovwmg3E4MPSXlujI42hwIieP2rGlpm5CWkSWp0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5059!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231218071249879270"
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
  name           = "acctest-kce-231218071249879270"
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
  name                     = "sa231218071249879270"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231218071249879270"
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
  name       = "acctest-fc-231218071249879270"
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
