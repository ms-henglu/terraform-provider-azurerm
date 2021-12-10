
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sql-211210035423870"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctest211210035423870"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctest2211210035423870"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver211210035423870"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"

  extended_auditing_policy {
    storage_account_access_key              = azurerm_storage_account.test2.primary_access_key
    storage_endpoint                        = azurerm_storage_account.test2.primary_blob_endpoint
    storage_account_access_key_is_secondary = false
    retention_in_days                       = 11
  }
}
