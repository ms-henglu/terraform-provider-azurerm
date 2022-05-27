
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-220527034011100290"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctvnk8o"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainervnk8o"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_subscription_cost_management_export" "test" {
  name                         = "accs220527034011100290"
  subscription_id              = data.azurerm_subscription.test.id
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2022-05-28T00:00:00Z"
  recurrence_period_end_date   = "2022-05-29T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
