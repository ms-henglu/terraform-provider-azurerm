
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072117794965"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet211013072117794965"
  address_space       = ["10.7.29.0/24"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test1" {
  name                 = "subnet1211013072117794965"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.7.29.0/25"
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "test2" {
  name                 = "subnet2211013072117794965"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.7.29.128/25"
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mariadb_server" "test" {
  name                         = "acctestmariadbsvr-211013072117794965"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "10.2"
  ssl_enforcement_enabled      = true
  sku_name                     = "GP_Gen5_2"

  storage_profile {
    storage_mb            = 51200
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }
}

resource "azurerm_mariadb_virtual_network_rule" "test" {
  name                = "acctestmariadbvnetrule211013072117794965"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mariadb_server.test.name
  subnet_id           = azurerm_subnet.test1.id
}
