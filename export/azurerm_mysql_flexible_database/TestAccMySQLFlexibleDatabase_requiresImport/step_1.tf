

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035041236513"
  location = "West Europe"
}
resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-221222035041236513"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "1"
}

resource "azurerm_mysql_flexible_database" "test" {
  name                = "acctestdb_221222035041236513"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_flexible_server.test.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


resource "azurerm_mysql_flexible_database" "import" {
  name                = azurerm_mysql_flexible_database.test.name
  resource_group_name = azurerm_mysql_flexible_database.test.resource_group_name
  server_name         = azurerm_mysql_flexible_database.test.server_name
  charset             = azurerm_mysql_flexible_database.test.charset
  collation           = azurerm_mysql_flexible_database.test.collation
}
