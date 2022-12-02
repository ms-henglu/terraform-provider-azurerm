

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040106496251"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest221202040106496251"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_elasticpool" "test" {
  name                = "acctest-pool-dtu-221202040106496251"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  server_name         = azurerm_mssql_server.test.name
  max_size_gb         = 4.8828125
  zone_redundant      = false

  maintenance_configuration_name = "Basic" != "Basic" && azurerm_resource_group.test.location == "westeurope" ? "SQL_WestEurope_DB_2" : "SQL_Default"

  sku {
    name     = "BasicPool"
    tier     = "Basic"
    capacity = 50
  }

  per_database_settings {
    min_capacity = 0
    max_capacity = 5
  }
}


resource "azurerm_mssql_elasticpool" "import" {
  name                = azurerm_mssql_elasticpool.test.name
  resource_group_name = azurerm_mssql_elasticpool.test.resource_group_name
  location            = azurerm_mssql_elasticpool.test.location
  server_name         = azurerm_mssql_elasticpool.test.server_name
  max_size_gb         = 4.8828125

  sku {
    name     = "BasicPool"
    tier     = "Basic"
    capacity = 50
  }

  per_database_settings {
    min_capacity = 0
    max_capacity = 5
  }
}
