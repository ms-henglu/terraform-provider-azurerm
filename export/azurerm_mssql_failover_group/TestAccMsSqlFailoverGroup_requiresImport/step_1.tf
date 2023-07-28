


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728030236846384"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test_primary" {
  name                         = "acctestmssql230728030236846384-primary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_server" "test_secondary" {
  name                         = "acctestmssql230728030236846384-secondary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = "West US 2"
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_database" "test" {
  name        = "acctestdb230728030236846384"
  server_id   = azurerm_mssql_server.test_primary.id
  sku_name    = "S1"
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = "200"
}


resource "azurerm_mssql_failover_group" "test" {
  name      = "acctestsfg230728030236846384"
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


resource "azurerm_mssql_failover_group" "import" {
  name      = azurerm_mssql_failover_group.test.name
  server_id = azurerm_mssql_failover_group.test.server_id
  databases = azurerm_mssql_failover_group.test.databases
  tags      = azurerm_mssql_failover_group.test.tags

  partner_server {
    id = azurerm_mssql_failover_group.test.partner_server[0].id
  }

  read_write_endpoint_failover_policy {
    mode          = azurerm_mssql_failover_group.test.read_write_endpoint_failover_policy[0].mode
    grace_minutes = azurerm_mssql_failover_group.test.read_write_endpoint_failover_policy[0].grace_minutes
  }
}
