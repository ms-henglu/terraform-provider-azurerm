
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227180037206527"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "test230227180037206527"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver230227180037206527"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"

  threat_detection_policy {
    retention_days             = 15
    state                      = "Disabled"
    disabled_alerts            = ["Sql_Injection"]
    email_account_admins       = true
    storage_account_access_key = azurerm_storage_account.test.primary_access_key
    storage_endpoint           = azurerm_storage_account.test.primary_blob_endpoint
  }
}
