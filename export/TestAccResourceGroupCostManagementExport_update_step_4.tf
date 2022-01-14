
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-220114063959222066"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctj0ksc"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainerj0ksc"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_resource_group_cost_management_export" "test" {
  name                         = "accrg220114063959222066"
  resource_group_id            = azurerm_resource_group.test.id
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2022-01-15T00:00:00Z"
  recurrence_period_end_date   = "2022-01-16T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }
  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
