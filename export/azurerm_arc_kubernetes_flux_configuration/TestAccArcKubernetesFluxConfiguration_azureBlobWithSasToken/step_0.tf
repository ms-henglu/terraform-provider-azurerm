
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223948745429"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112223948745429"
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
  name                = "acctestpip-240112223948745429"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112223948745429"
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
  name                            = "acctestVM-240112223948745429"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd4204!"
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
  name                         = "acctest-akcc-240112223948745429"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA1+3b9L1D/4HolCbnDjupsNEDnIlMZvwXslKvrmOsZuI+VRSzc07/TI+MuJ7ChdE11/G7a6aIHDjEIa5O/tLjCdqJyoIHVW0wW+5szWNgEojeVrltx0YKDVlmjuV+23ontPQ4DaCnaZNG3B7g6X0tMADEocMf+TtDSFiB1hgVg5J/z4OfnipI4qFAIM3dJ4AM6s+Vz3VLMPbUlpPfqpTgKi1xvocYIHTbW/2AOWDQrrV/ZBODi/h/w6cO67ZdUlMirSyRUpKlYBhsNLBIuOVLLQx8KTo8+SxsfEPJN+82Rv+gGW3FKSahrl48UNTxYNNeR977nLkDwXcabTRSMgdXGiVxxPme6o/5+JBLN2ls4XQJZHaHSN1DTWgki7RenpZtuENucJfKuCsc/n4Ud3Ek9M4UFpleIHtDmhJRLh7U1xmEdT68dO0JDjffrw9U6q1rBZSy6xRwscmtVdDg6EtvHTzkR1VG9DqzOKkVijP5BJUAwXSQpt4WaGPDqHI4OMKdZDWFzwptgiWoA8ZdYGlRuO0aUCgjD3zh2/cEyDzw6/uocU25WS+7auNAxEh1DbpljPsxOs6oLj1K2jxjuC0PvhpbGlgCsZQDCmILknRbx7fYdKN+A6GPSbBfR9/ZK6s8dl70Lgqmr3fXBYdDRkUI/T+ekI6Rv5bGbALbQEDY9v0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd4204!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112223948745429"
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
  name           = "acctest-kce-240112223948745429"
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
  name                     = "sa240112223948745429"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240112223948745429"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true
  signed_version    = "2019-10-10"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2024-01-11T22:39:48Z"
  expiry = "2024-01-14T22:39:48Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = false
  }
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240112223948745429"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    sas_token    = data.azurerm_storage_account_sas.test.sas
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
