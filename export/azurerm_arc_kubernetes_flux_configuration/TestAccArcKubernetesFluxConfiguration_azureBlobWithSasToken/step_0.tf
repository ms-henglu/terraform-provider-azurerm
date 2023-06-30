
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032706506715"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230630032706506715"
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
  name                = "acctestpip-230630032706506715"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230630032706506715"
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
  name                            = "acctestVM-230630032706506715"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd121!"
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
  name                         = "acctest-akcc-230630032706506715"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAtp1qsdIqGsG4irN1lAhH1tuq+5pTKKExz9VPvXb9usDqnGUvKA9h3hRGgezBqi/MCdPofTu10AOeLbCFaHYehmVsfsFj4KMsusPB+455slf3YPqEpHah02xzf5arskHHlGEtZ3ZYnUIBxgcabqVCAxfjsPzfk8to5pNhzNPmXggGyiPcvIzQdS80mWK+3qWHJfd/bex5YC+3FkQRwgW/qgwWHBZkiRtuK1+rMDaShTSTwUjh8Dr/8eNqUil+AlUKsheS7zlFaa4tMuA3MZck91xPf0zBKLYKYos8WlyODlG7ClDhSACg9g7ZDqWEGbb4cVUvEWxi1F4v2bdBAhA17j0VeoqnOjtqjJ59c14pErsXgEHVF+ai+MCcjnoanYNcbIc/igZR6WyBEW9XJ7CBr7db9lrgT1jCaPB5hgBYrHWB1+gJJxFJJJ2/4AovNv52RLYz8i2ZTy3UyrEdKd8bT0n5a66GuF3sIwkmw3GjCojYMCutULZL3ndqbIR8besLGt/JJZwdAJ7A/DnOBAAJx0qh4G0ODb6MZ7/AV/y1lArcAkf/0kLPs7FkiiqVgSutATw4POIVq6+ux1xlmjrNlmkLiYxTd8JAqRVNgit3FAKSj5a1b9rNtZFdGrRkxANawz87iyVdufaYv8HaUuBGZCY7zqL+HdhaFVa3OBoi2KsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd121!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230630032706506715"
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
  name           = "acctest-kce-230630032706506715"
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
  name                     = "sa230630032706506715"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230630032706506715"
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

  start  = "2023-06-29T03:27:06Z"
  expiry = "2023-07-02T03:27:06Z"

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
  name       = "acctest-fc-230630032706506715"
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
