

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021703247777"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet210910021703247777"
  address_space       = ["10.7.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet210910021703247777"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.7.29.0/29"
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mysql_server" "test" {
  name                         = "acctestmysqlsvr-210910021703247777"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "5.6"
  ssl_enforcement_enabled      = true

  sku_name = "GP_Gen5_2"

  storage_profile {
    storage_mb            = 51200
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }
}

resource "azurerm_mysql_virtual_network_rule" "test" {
  name                = "acctestmysqlvnetrule210910021703247777"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_server.test.name
  subnet_id           = azurerm_subnet.test.id
}


resource "azurerm_mysql_virtual_network_rule" "import" {
  name                = azurerm_mysql_virtual_network_rule.test.name
  resource_group_name = azurerm_mysql_virtual_network_rule.test.resource_group_name
  server_name         = azurerm_mysql_virtual_network_rule.test.server_name
  subnet_id           = azurerm_mysql_virtual_network_rule.test.subnet_id
}
