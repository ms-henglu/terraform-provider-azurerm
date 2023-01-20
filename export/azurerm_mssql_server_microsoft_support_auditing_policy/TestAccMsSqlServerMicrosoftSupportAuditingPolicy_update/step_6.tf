

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230120052408987611"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230120052408987611"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "AdminPassword123!"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct6lcfh"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_account" "test2" {
  name                     = "unlikely23exst2acc26lcfh"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server_microsoft_support_auditing_policy" "test" {
  server_id                  = azurerm_mssql_server.test.id
  blob_storage_endpoint      = azurerm_storage_account.test2.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.test2.primary_access_key
}
