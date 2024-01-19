

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240119025436761906"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-240119025436761906"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-240119025436761906"
  server_id    = azurerm_mssql_server.test.id
  collation    = "SQL_AltDiction_CP850_CI_AI"
  license_type = "BasePrice"
  max_size_gb  = 1
  sample_name  = "AdventureWorksLT"
  sku_name     = "GP_Gen5_2"

  threat_detection_policy {
    retention_days       = 15
    state                = "Enabled"
    disabled_alerts      = ["Sql_Injection"]
    email_account_admins = "Enabled"
  }

  tags = {
    ENV = "Test"
  }
}
