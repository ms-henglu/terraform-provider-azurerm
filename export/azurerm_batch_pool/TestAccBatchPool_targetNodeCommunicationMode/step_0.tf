
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240119024553056713"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatche1a2u"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoole1a2u"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 22.04"
  vm_size             = "Standard_A1"

  target_node_communication_mode = "Default"

  fixed_scale {
    target_dedicated_nodes = 1
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
