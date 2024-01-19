


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-240119025622770494"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-240119025622770494"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "2"
}


resource "azurerm_postgresql_flexible_server" "pitr" {
  name                              = "acctest-fs-pitr-240119025622770494"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  create_mode                       = "PointInTimeRestore"
  source_server_id                  = azurerm_postgresql_flexible_server.test.id
  zone                              = "1"
  point_in_time_restore_time_in_utc = "2024-01-19T03:11:22Z"
}
