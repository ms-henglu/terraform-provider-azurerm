
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034800858076"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet231016034800858076"
  address_space       = ["10.7.29.0/24"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test1" {
  name                 = "subnet1231016034800858076"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/25"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "test2" {
  name                 = "subnet2231016034800858076"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.128/25"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver231016034800858076"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadmin"
  administrator_login_password = "${md5(231016034800858076)}!"
}

resource "azurerm_sql_virtual_network_rule" "test" {
  name                = "acctestsqlvnetrule231016034800858076"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_sql_server.test.name
  subnet_id           = azurerm_subnet.test2.id
}
