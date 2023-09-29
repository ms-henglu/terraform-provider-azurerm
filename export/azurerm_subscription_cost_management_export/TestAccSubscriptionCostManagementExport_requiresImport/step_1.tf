

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230929064646074389"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctimadq"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainerimadq"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_subscription_cost_management_export" "test" {
  name                         = "accs230929064646074389"
  subscription_id              = data.azurerm_subscription.test.id
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2023-09-30T00:00:00Z"
  recurrence_period_end_date   = "2023-10-01T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}


resource "azurerm_subscription_cost_management_export" "import" {
  name                         = azurerm_subscription_cost_management_export.test.name
  subscription_id              = azurerm_subscription_cost_management_export.test.subscription_id
  recurrence_type              = azurerm_subscription_cost_management_export.test.recurrence_type
  recurrence_period_start_date = azurerm_subscription_cost_management_export.test.recurrence_period_start_date
  recurrence_period_end_date   = azurerm_subscription_cost_management_export.test.recurrence_period_start_date

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
