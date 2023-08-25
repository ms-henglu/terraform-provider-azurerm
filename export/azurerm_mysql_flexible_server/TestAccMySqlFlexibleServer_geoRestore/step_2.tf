


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-230825024954803488"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                         = "acctest-fs-230825024954803488"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "adminTerraform"
  administrator_password       = "QAZwsx123"
  geo_redundant_backup_enabled = true
  sku_name                     = "B_Standard_B1s"
}


resource "azurerm_mysql_flexible_server" "geo_restore" {
  name                = "acctest-fs-restore-230825024954803488"
  resource_group_name = azurerm_resource_group.test.name
  location            = "ARM_GEO_RESTORE_LOCATION"
  create_mode         = "GeoRestore"
  source_server_id    = azurerm_mysql_flexible_server.test.id
}
