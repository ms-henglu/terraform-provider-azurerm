
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230120051745758307"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctcsux8"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainercsux8"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_subscription_cost_management_export" "test" {
  name                         = "accs230120051745758307"
  subscription_id              = data.azurerm_subscription.test.id
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2023-01-21T00:00:00Z"
  recurrence_period_end_date   = "2023-01-22T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
