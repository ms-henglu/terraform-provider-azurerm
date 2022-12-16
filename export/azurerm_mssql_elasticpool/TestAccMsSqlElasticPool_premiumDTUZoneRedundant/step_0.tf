
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013903848469"
  location = "westeurope"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest221216013903848469"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_elasticpool" "test" {
  name                = "acctest-pool-dtu-221216013903848469"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  server_name         = azurerm_mssql_server.test.name
  max_size_gb         = 50.0000000
  zone_redundant      = true

  maintenance_configuration_name = "Premium" != "Basic" && azurerm_resource_group.test.location == "westeurope" ? "SQL_WestEurope_DB_2" : "SQL_Default"

  sku {
    name     = "PremiumPool"
    tier     = "Premium"
    capacity = 125
  }

  per_database_settings {
    min_capacity = 0
    max_capacity = 50
  }
}
