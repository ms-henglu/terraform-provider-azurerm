


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-221021034447719625"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-221021034447719625"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "2"
}


resource "azurerm_postgresql_flexible_server_database" "test" {
  name      = "acctest-fsd-221021034447719625"
  server_id = azurerm_postgresql_flexible_server.test.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}
