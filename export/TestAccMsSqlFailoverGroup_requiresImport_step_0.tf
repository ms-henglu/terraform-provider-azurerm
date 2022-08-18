

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235431825043"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test_primary" {
  name                         = "acctestmssql220818235431825043-primary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_server" "test_secondary" {
  name                         = "acctestmssql220818235431825043-secondary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = "West US 2"
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_database" "test" {
  name        = "acctestdb220818235431825043"
  server_id   = azurerm_mssql_server.test_primary.id
  sku_name    = "S1"
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = "200"
}


resource "azurerm_mssql_failover_group" "test" {
  name      = "acctestsfg220818235431825043"
  server_id = azurerm_mssql_server.test_primary.id
  databases = [azurerm_mssql_database.test.id]

  partner_server {
    id = azurerm_mssql_server.test_secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 80
  }

  tags = {
    environment = "prod"
    database    = "test"
  }
}
