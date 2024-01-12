
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224909455026"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest240112224909455026"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_elasticpool" "test" {
  name                           = "acctest-pool-dtu-240112224909455026"
  resource_group_name            = azurerm_resource_group.test.name
  location                       = azurerm_resource_group.test.location
  server_name                    = azurerm_mssql_server.test.name
  max_size_gb                    = 4.8828125
  zone_redundant                 = false
  maintenance_configuration_name = "SQL_Default"
  

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
