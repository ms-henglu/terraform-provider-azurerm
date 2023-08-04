
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030355228594"
  location = "West Europe"
}
resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-230804030355228594"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "1"
}

resource "azurerm_mysql_flexible_database" "test" {
  name                = "acctestdb_230804030355228594"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_flexible_server.test.name
  charset             = "UTF8"
  collation           = "utf8_unicode_ci"
}
