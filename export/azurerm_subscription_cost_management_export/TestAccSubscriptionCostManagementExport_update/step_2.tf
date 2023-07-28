
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230728025417728591"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctagk9o"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontaineragk9o"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_subscription_cost_management_export" "test" {
  name                         = "accrg230728025417728591"
  subscription_id              = data.azurerm_subscription.test.id
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2023-10-28T00:00:00Z"
  recurrence_period_end_date   = "2023-11-28T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root/updated"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "WeekToDate"
  }
}
