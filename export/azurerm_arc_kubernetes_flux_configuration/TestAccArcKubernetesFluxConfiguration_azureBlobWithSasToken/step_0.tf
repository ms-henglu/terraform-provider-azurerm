
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022915856249"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230915022915856249"
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
  name                = "acctestpip-230915022915856249"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230915022915856249"
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
  name                            = "acctestVM-230915022915856249"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd8200!"
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
  name                         = "acctest-akcc-230915022915856249"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAvvKSHvYmVjMgy+HqJPiFnB4vZnjFB1Rk3ZRN4AxtNFjUVQQRw2sv9u2qT/Kk0ws6wZjCHLH2+VRQxFGAwdbE9LmU1uxMkEpkRPGpD60qBNkWVudGtN2HR6m7bfKw1nzylyvhMotHcNNg+oZ/wwB0BH1bAl4oUSWReWRVRvvMAMNVrshRRfpZFqxi3ityhsxkWvVck98hG0cwsPvFZ4wQd/76009Xd1SDAJXCbgbsAu+vtBb7l6KXbFY80Mk6q8OIM4L/hPy0iiUPS209AoppHhIxS9MVjxCpjd6LAnBcPk/1u0SZ/Dwf95naPctP06aqoX/d9aItS1U09VTZLV9dtdXjgZGL51hh4xC3YB074bNMGFmXBZDeV3BZVX7gsxPUphqxmwxDF32nV2FJnXQMwCuUx99OVyFJifRPsEyrJvoOiGjt1S2oUVXsDwM81IsEy8RNUzPqy5cehPv7sRBsbs52N/ME306EJtVCexoygMIllHY5G13FrVieFqM34YEz+lFSBgMfuspNnjDRSOesVjlPPqWA4J3L9V2Ew26Mh23f6bdva3cIhhdpf3Ohs0xiRskByb1j6FW+kJFU5JJHEeu3jb3rWieRq9AM7JdpVKJUfQrkBaFekU++ckXLQu95B6LfMMFyma46dqJhFQX2hRHE82pHOy3hNHjt6SY2qtsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd8200!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230915022915856249"
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
  name           = "acctest-kce-230915022915856249"
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
  name                     = "sa230915022915856249"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230915022915856249"
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

  start  = "2023-09-14T02:29:15Z"
  expiry = "2023-09-17T02:29:15Z"

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
  name       = "acctest-fc-230915022915856249"
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
