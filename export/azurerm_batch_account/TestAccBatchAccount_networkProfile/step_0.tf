
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231016033447867096"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchciup8"
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
