
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-211210034516289832"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctc3kde"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_cost_management_export_resource_group" "test" {
  name                    = "accrg211210034516289832"
  resource_group_id       = azurerm_resource_group.test.id
  recurrence_type         = "Monthly"
  recurrence_period_start = "2021-12-11T00:00:00Z"
  recurrence_period_end   = "2021-12-12T00:00:00Z"

  delivery_info {
    storage_account_id = azurerm_storage_account.test.id
    container_name     = "acctestcontainer"
    root_folder_path   = "/root"
  }

  query {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
