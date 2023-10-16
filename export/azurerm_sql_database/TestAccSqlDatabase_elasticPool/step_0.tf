
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034800831010"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver231016034800831010"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_elasticpool" "test" {
  name                = "acctestep231016034800831010"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  server_name         = azurerm_sql_server.test.name
  edition             = "Basic"
  dtu                 = 50
  pool_size           = 5000
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb231016034800831010"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test.name
  location                         = azurerm_resource_group.test.location
  edition                          = azurerm_sql_elasticpool.test.edition
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  elastic_pool_name                = azurerm_sql_elasticpool.test.name
  requested_service_objective_name = "ElasticPool"
}
