


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-211015014549109315"
  location = "West Europe"
}


resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-211015014549109315"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  sku_name               = "GP_Standard_D4ds_v4"
}


resource "azurerm_mysql_flexible_server" "replica" {
  name                = "acctest-fs-replica-211015014549109315"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  create_mode         = "Replica"
  source_server_id    = azurerm_mysql_flexible_server.test.id
}
