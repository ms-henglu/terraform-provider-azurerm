
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240112033924672024"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch78cb9"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  network_profile {
    account_access {
    }

    node_management_access {
    }
  }
}
