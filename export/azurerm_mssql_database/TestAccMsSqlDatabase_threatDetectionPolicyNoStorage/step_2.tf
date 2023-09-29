

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230929065324035956"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230929065324035956"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_storage_account" "test" {
  name                     = "test230929065324035956"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-230929065324035956"
  server_id    = azurerm_mssql_server.test.id
  collation    = "SQL_AltDiction_CP850_CI_AI"
  license_type = "BasePrice"
  max_size_gb  = 1
  sample_name  = "AdventureWorksLT"
  sku_name     = "GP_Gen5_2"

  threat_detection_policy {
    retention_days             = 15
    state                      = "Enabled"
    disabled_alerts            = ["Sql_Injection"]
    email_account_admins       = "Enabled"
    storage_account_access_key = azurerm_storage_account.test.primary_access_key
    storage_endpoint           = azurerm_storage_account.test.primary_blob_endpoint
  }

  tags = {
    ENV = "Test"
  }
}
