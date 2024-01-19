
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022502163196"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest240119022502163196"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_elasticpool" "test" {
  name                           = "acctest-pool-dtu-240119022502163196"
  resource_group_name            = azurerm_resource_group.test.name
  location                       = azurerm_resource_group.test.location
  server_name                    = azurerm_mssql_server.test.name
  max_size_gb                    = 100.0000000
  zone_redundant                 = false
  maintenance_configuration_name = "SQL_Default"
  enclave_type = "VBS"

  sku {
    name     = "StandardPool"
    tier     = "Standard"
    capacity = 100
  }

  per_database_settings {
    min_capacity = 50
    max_capacity = 100
  }
}
