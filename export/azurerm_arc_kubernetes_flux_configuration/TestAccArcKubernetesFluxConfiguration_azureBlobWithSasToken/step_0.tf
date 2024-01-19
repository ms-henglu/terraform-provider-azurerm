
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024517622415"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240119024517622415"
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
  name                = "acctestpip-240119024517622415"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240119024517622415"
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
  name                            = "acctestVM-240119024517622415"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd2201!"
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
  name                         = "acctest-akcc-240119024517622415"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAqRAV4d49r5+ntSIJ5Jisl+/naW7HcJRbWky4ENxWrmMUjz0e4RfJ0kkqDp4PCphVwDyZUexEUZRuAwgZHJRrZp2KpIgp6Y4/8QOOxpiHFrj1NN8FXqo0cVozLJF7JQPs48TINK8gIIsQHPCuSASdHDaBJrN5DnlBIQhWJMkBHJpCysinSRIuIkbFpWcm0+I+Gklj2kMtr7LQ5FD48GmCMUeI2n49dNFGiL6B0pEu4MVEmt7YdWVBgRpZrZiYRXp8JeJeqIKA2DlqzizG6UcbdRGSuDALu518vL/+1MkgQWcwyfew5beanbJsCgenWcrVR4jd/3n9yRhYbOMpzPETKzLvNy+jnvAEcHTxDa1fNXzMCTWmSJFUaonARygi5DLN5D8J7rSplwpvupKbbpdisFk4ARR+nwl8BcTQd4bquzkiq1aKlslBpQuNz7h0332YVpPGRJ9YQ62PCpu2NHsNVL/PzNf79bx62y+6OG968wimzUwSMQZgfefD1JKq6W98nXzYASkhpYTBLztjaYbhC/gc5axY9ZeuYqLzJsD+fmOCUIX8eqdUKv/9hvcFKEq3nT3ifWQx6zIkGb+Cgu/orafgbJYzR7s3cyy8LmdqBShaRjBCzzEaEHQosKqh1pW/dqcuo2mB82AHYYKgH9SsGhpayFDt6X7YCJA+JZbJ/2sCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd2201!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240119024517622415"
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
  name           = "acctest-kce-240119024517622415"
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
  name                     = "sa240119024517622415"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240119024517622415"
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

  start  = "2024-01-18T02:45:17Z"
  expiry = "2024-01-21T02:45:17Z"

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
  name       = "acctest-fc-240119024517622415"
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
