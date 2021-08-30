
resource "azurerm_resource_group" "test" {
  name     = "testaccRG-210830083717834300-batchpool"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet210830083717834300"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-210830083717834300"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "acctest-publicip-210830083717834300"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatch1p8dw"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool1p8dw"
  resource_group_name = "${azurerm_resource_group.test.name}"
  account_name        = "${azurerm_batch_account.test.name}"
  node_agent_sku_id   = "batch.node.ubuntu 16.04"
  vm_size             = "Standard_A1"

  fixed_scale {
    target_dedicated_nodes = 1
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  network_configuration {
    public_address_provisioning_type = "UserManaged"
    public_ips                       = [azurerm_public_ip.test.id]
    subnet_id                        = azurerm_subnet.test.id

    endpoint_configuration {
      name                = "SSH"
      protocol            = "TCP"
      backend_port        = 22
      frontend_port_range = "4000-4100"

      network_security_group_rules {
        access                = "Deny"
        priority              = 1001
        source_address_prefix = "*"
      }
    }
  }
}
