

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004416270727"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet230707004416270727"
  address_space       = ["10.7.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet230707004416270727"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mysql_server" "test" {
  name                         = "acctestmysqlsvr-230707004416270727"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "5.7"
  ssl_enforcement_enabled      = true

  sku_name = "GP_Gen5_2"

  storage_mb                   = 51200
  geo_redundant_backup_enabled = false
  backup_retention_days        = 7
}

resource "azurerm_mysql_virtual_network_rule" "test" {
  name                = "acctestmysqlvnetrule230707004416270727"
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
