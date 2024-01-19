

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240119025436763001"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-240119025436763001"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_elasticpool" "test" {
  name                = "acctest-pool-240119025436763001"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  server_name         = azurerm_mssql_server.test.name
  max_size_gb         = 5

  sku {
    name     = "GP_Gen5"
    tier     = "GeneralPurpose"
    capacity = 4
    family   = "Gen5"
  }

  per_database_settings {
    min_capacity = 0.25
    max_capacity = 4
  }
}

resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-240119025436763001"
  server_id = azurerm_mssql_server.test.id
  sku_name  = "GP_Gen5_2"
}
