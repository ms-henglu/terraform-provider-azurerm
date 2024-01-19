
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-240119024757245340"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctf8byi"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainerf8byi"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_resource_group_cost_management_export" "test" {
  name                         = "accrg240119024757245340"
  resource_group_id            = azurerm_resource_group.test.id
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2024-01-20T00:00:00Z"
  recurrence_period_end_date   = "2024-01-21T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }
  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
