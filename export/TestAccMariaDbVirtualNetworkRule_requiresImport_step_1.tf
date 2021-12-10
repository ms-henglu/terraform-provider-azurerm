

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024813338044"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet211210024813338044"
  address_space       = ["10.7.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet211210024813338044"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.7.29.0/29"
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mariadb_server" "test" {
  name                         = "acctestmariadbsvr-211210024813338044"
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
  name                = "acctestmariadbvnetrule211210024813338044"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mariadb_server.test.name
  subnet_id           = azurerm_subnet.test.id
}


resource "azurerm_mariadb_virtual_network_rule" "import" {
  name                = azurerm_mariadb_virtual_network_rule.test.name
  resource_group_name = azurerm_mariadb_virtual_network_rule.test.resource_group_name
  server_name         = azurerm_mariadb_virtual_network_rule.test.server_name
  subnet_id           = azurerm_mariadb_virtual_network_rule.test.subnet_id
}
