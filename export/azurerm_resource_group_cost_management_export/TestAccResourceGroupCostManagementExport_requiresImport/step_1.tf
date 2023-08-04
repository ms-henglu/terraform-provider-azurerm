

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230804025712973541"
  location = "West Europe"
}
resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct9p79u"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                 = "acctestcontainer9p79u"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_resource_group_cost_management_export" "test" {
  name                         = "accrg230804025712973541"
  resource_group_id            = azurerm_resource_group.test.id
  recurrence_type              = "Monthly"
  recurrence_period_start_date = "2023-08-05T00:00:00Z"
  recurrence_period_end_date   = "2023-08-06T00:00:00Z"

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }
  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}


resource "azurerm_resource_group_cost_management_export" "import" {
  name                         = azurerm_resource_group_cost_management_export.test.name
  resource_group_id            = azurerm_resource_group.test.id
  recurrence_type              = azurerm_resource_group_cost_management_export.test.recurrence_type
  recurrence_period_start_date = azurerm_resource_group_cost_management_export.test.recurrence_period_start_date
  recurrence_period_end_date   = azurerm_resource_group_cost_management_export.test.recurrence_period_start_date

  export_data_storage_location {
    container_id     = azurerm_storage_container.test.resource_manager_id
    root_folder_path = "/root"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "TheLastMonth"
  }
}
