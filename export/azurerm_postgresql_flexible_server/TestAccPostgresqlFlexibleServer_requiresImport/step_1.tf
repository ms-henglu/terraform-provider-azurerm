


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-postgresql-240105061351069073"
  location = "West Europe"
}


resource "azurerm_postgresql_flexible_server" "test" {
  name                   = "acctest-fs-240105061351069073"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D2s_v3"
  zone                   = "2"
}


resource "azurerm_postgresql_flexible_server" "import" {
  name                   = azurerm_postgresql_flexible_server.test.name
  resource_group_name    = azurerm_postgresql_flexible_server.test.resource_group_name
  location               = azurerm_postgresql_flexible_server.test.location
  administrator_login    = azurerm_postgresql_flexible_server.test.administrator_login
  administrator_password = azurerm_postgresql_flexible_server.test.administrator_password
  version                = azurerm_postgresql_flexible_server.test.version
  storage_mb             = azurerm_postgresql_flexible_server.test.storage_mb
  sku_name               = azurerm_postgresql_flexible_server.test.sku_name
  zone                   = azurerm_postgresql_flexible_server.test.zone
}
