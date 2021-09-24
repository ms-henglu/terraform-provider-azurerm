


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-210924004714531428"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-210924004714531428"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
}


resource "azurerm_postgresql_flexible_server_database" "test" {
  name      = "acctest-fsd-210924004714531428"
  server_id = azurerm_postgresql_flexible_server.test.id
  collation = "en_US.latin1"
  charset   = "latin1"
}
