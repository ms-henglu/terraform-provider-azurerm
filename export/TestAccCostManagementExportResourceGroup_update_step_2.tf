
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-211008044230701358"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctq4ebm"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_cost_management_export_resource_group" "test" {
  name                    = "accrg211008044230701358"
  resource_group_id       = azurerm_resource_group.test.id
  recurrence_type         = "Monthly"
  recurrence_period_start = "2022-01-08T00:00:00Z"
  recurrence_period_end   = "2022-02-08T00:00:00Z"

  delivery_info {
    storage_account_id = azurerm_storage_account.test.id
    container_name     = "acctestcontainer"
    root_folder_path   = "/root/updated"
  }

  query {
    type       = "Usage"
    time_frame = "WeekToDate"
  }
}
