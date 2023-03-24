
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052455215539"
  location = "West Europe"
}

resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-230324052455215539"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "1"
}

resource "azurerm_mysql_flexible_server_configuration" "test" {
  name                = "character_set_server"
  resource_group_name = "${azurerm_resource_group.test.name}"
  server_name         = "${azurerm_mysql_flexible_server.test.name}"
  value               = "hebrew"
}
