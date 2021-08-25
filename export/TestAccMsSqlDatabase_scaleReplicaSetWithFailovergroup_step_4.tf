
	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-210825045035687150"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-210825045035687150"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-210825045035687150"
  server_id    = azurerm_sql_server.test.id
  collation    = "SQL_AltDiction_CP850_CI_AI"
  license_type = "BasePrice"
  max_size_gb  = 5
  sample_name  = "AdventureWorksLT"
  sku_name     = "GP_Gen5_2"

  tags = {
    ENV = "Test"
  }
}

resource "azurerm_resource_group" "second" {
  name     = "acctestRG-mssql2-210825045035687150"
  location = "West US 2"
}

resource "azurerm_sql_server" "second" {
  name                         = "acctest-sqlserver2-210825045035687150"
  resource_group_name          = azurerm_resource_group.second.name
  location                     = azurerm_resource_group.second.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_database" "secondary" {
  name                        = "acctest-db-210825045035687150"
  server_id                   = azurerm_sql_server.second.id
  create_mode                 = "Secondary"
  creation_source_database_id = azurerm_mssql_database.test.id
  sku_name                    = "GP_Gen5_2"
}

resource "azurerm_sql_failover_group" "failover_group" {
  depends_on          = [azurerm_mssql_database.test, azurerm_mssql_database.secondary]
  name                = "acctest-fog-210825045035687150"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_sql_server.test.name
  databases           = [azurerm_mssql_database.test.id]
  partner_servers {
    id = azurerm_sql_server.second.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 5
  }
}
