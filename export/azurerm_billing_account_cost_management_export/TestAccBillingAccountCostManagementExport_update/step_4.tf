
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230106031302825551"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct7wfmg"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainer7wfmg"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_billing_account_cost_management_export" "test" {
  name                         = "accs230106031302825551"
  billing_account_id           = "ARM_BILLING_ACCOUNT"
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2023-01-07T00:00:00Z"
  recurrence_period_end_date   = "2023-01-08T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
