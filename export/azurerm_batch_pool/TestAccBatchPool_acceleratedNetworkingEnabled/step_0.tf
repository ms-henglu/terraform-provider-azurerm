
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240315122405733236"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchx4sda"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoolx4sda"
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
