
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707010006501313"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230707010006501313"
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
  name                = "acctestpip-230707010006501313"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230707010006501313"
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
  name                            = "acctestVM-230707010006501313"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd5780!"
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
  name                         = "acctest-akcc-230707010006501313"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA4oGDKG9KHezyiaTACDSKsJJlhK1zabPh3Mc/pc5l09bJfs8/ehK/Qw2eBpUIB2CW4IRdCqkIql9Ys68LoauRp5E9DGXpgWK50g/hRDTRYDYkomPqQRzHo4nfUiipX/oDPq2YU6g9bu89Erol0rkJjF7B7rT771Q+n36jCNIRVniT44yx1n4yOYcGlqDm5R/8KwblRxBP7sL5GmcyC6b+2HIYyxjCUaiKx7W5OwLGjXhk0WYGQJQMDJf4tGOUFcj8jzK12G+frLDcZY8XUcdrUKs7If/5BN3cGUPnmx6XZj3QXTTcCglzY98Nry76s+GHqNiHtq5Uq6gQrb4eBhshlV1YtnFj/rCyGn3NDa0Orhsmk/dLRBy3wfYqLgYi5tBitUs14y8x8VT/RXp2QCksPOoRJPyFjL9KvgI/uELjkMQVkydXopn2Tozq8vDZQLgkscSu8GK27mj7LcOfK22LXEsHh9wuXflyWk4sqhZrhU9t1y9kjovaFQt+oC13OyHc4iKhugZm2p7voJ7l0pnYLAnILl1mp9Pou3ArvmjijHXeIVZtUsCLQr/uC+jRFhh2gv4pGmV8GCkH5/VjgQGAudPV7GZeGYbyPHaFwWsHj3NRtptCLPlIs/nyV2FGZnDKXEQkRjsA1nkPvhCRCCDyAXW8Vpwd2bQzkSWpYU6MMl0CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd5780!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230707010006501313"
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
  name           = "acctest-kce-230707010006501313"
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
  name                     = "sa230707010006501313"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc230707010006501313"
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

  start  = "2023-07-06T01:00:06Z"
  expiry = "2023-07-09T01:00:06Z"

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
  name       = "acctest-fc-230707010006501313"
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
