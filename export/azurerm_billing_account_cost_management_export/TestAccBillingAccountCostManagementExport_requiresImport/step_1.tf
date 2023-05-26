

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230526084851758066"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctmmbuo"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainermmbuo"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_billing_account_cost_management_export" "test" {
  name                         = "accs230526084851758066"
  billing_account_id           = "ARM_BILLING_ACCOUNT"
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2023-05-27T00:00:00Z"
  recurrence_period_end_date   = "2023-05-28T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}


resource "azurerm_billing_account_cost_management_export" "import" {
  name                         = azurerm_billing_account_cost_management_export.test.name
  billing_account_id           = azurerm_billing_account_cost_management_export.test.billing_account_id
  recurrence_type              = azurerm_billing_account_cost_management_export.test.recurrence_type
  recurrence_period_start_date = azurerm_billing_account_cost_management_export.test.recurrence_period_start_date
  recurrence_period_end_date   = azurerm_billing_account_cost_management_export.test.recurrence_period_start_date

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
