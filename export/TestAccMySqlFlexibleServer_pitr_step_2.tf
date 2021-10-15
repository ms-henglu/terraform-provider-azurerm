


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-211015014549108704"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-211015014549108704"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
}


resource "azurerm_mysql_flexible_server" "pitr" {
  name                              = "acctest-fs-pitr-211015014549108704"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  create_mode                       = "PointInTimeRestore"
  source_server_id                  = azurerm_mysql_flexible_server.test.id
  point_in_time_restore_time_in_utc = "2021-10-15T02:00:49Z"
}
