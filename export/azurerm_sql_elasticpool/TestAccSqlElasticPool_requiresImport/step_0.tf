
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050616770590"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest230428050616770590"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_sql_elasticpool" "test" {
  name                = "acctest-pool-230428050616770590"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  server_name         = azurerm_sql_server.test.name
  edition             = "Basic"
  dtu                 = 50
  pool_size           = 5000
}
