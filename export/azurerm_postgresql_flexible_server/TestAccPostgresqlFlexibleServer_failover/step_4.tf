

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-221124182132561676"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-221124182132561676"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  version                = "12"
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  zone                   = "2"
  backup_retention_days  = 10
  storage_mb             = 131072
  sku_name               = "GP_Standard_D2s_v3"

  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }
}
