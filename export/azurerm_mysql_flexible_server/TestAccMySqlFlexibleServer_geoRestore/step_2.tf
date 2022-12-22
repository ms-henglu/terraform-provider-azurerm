


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-221222035041249944"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                         = "acctest-fs-221222035041249944"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "adminTerraform"
  administrator_password       = "QAZwsx123"
  geo_redundant_backup_enabled = true
  sku_name                     = "B_Standard_B1s"
}


resource "azurerm_mysql_flexible_server" "geo_restore" {
  name                = "acctest-fs-restore-221222035041249944"
  resource_group_name = azurerm_resource_group.test.name
  location            = "ARM_GEO_RESTORE_LOCATION"
  create_mode         = "GeoRestore"
  source_server_id    = azurerm_mysql_flexible_server.test.id
}
