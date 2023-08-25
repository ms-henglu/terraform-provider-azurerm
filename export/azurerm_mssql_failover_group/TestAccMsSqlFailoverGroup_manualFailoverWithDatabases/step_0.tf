

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024940438202"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test_primary" {
  name                         = "acctestmssql230825024940438202-primary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_server" "test_secondary" {
  name                         = "acctestmssql230825024940438202-secondary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = "West US 2"
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_database" "test" {
  name        = "acctestdb230825024940438202"
  server_id   = azurerm_mssql_server.test_primary.id
  sku_name    = "S1"
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = "200"
}


resource "azurerm_mssql_failover_group" "test" {
  name      = "acctestsfg230825024940438202"
  server_id = azurerm_mssql_server.test_primary.id
  databases = [azurerm_mssql_database.test.id]

  partner_server {
    id = azurerm_mssql_server.test_secondary.id
  }

  read_write_endpoint_failover_policy {
    mode = "Manual"
  }

  tags = {
    environment = "staging"
    database    = "test"
  }
}
