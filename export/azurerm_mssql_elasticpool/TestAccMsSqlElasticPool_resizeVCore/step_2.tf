
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061545330767"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest230922061545330767"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_elasticpool" "test" {
  name                = "acctest-pool-vcore-230922061545330767"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  server_name         = azurerm_mssql_server.test.name
  max_size_gb         = 5
  sku {
    name     = "GP_Gen5"
    tier     = "GeneralPurpose"
    capacity = 8
    family   = "Gen5"
  }

  per_database_settings {
    min_capacity = 0.00
    max_capacity = 8.00
  }
}
