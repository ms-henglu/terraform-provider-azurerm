
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231013043014389133"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatcha6c0p"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoola6c0p"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.windows amd64"
  vm_size             = "Standard_D1_v2"

  fixed_scale {
    target_dedicated_nodes = 2
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-datacenter-smalldisk"
    version   = "latest"
  }

  network_configuration {
    accelerated_networking_enabled = true
  }
}
