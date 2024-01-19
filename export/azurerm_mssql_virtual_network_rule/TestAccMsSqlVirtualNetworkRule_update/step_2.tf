

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025436790900"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet240119025436790900"
  address_space       = ["10.7.28.0/23"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test1" {
  name                 = "subnet1240119025436790900"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.28.0/25"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "test2" {
  name                 = "subnet2240119025436790900"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.28.128/25"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "test3" {
  name                 = "subnet3240119025436790900"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/25"]
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver240119025436790900"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadmin"
  administrator_login_password = "P@55W0rD!!iyihk"
}


resource "azurerm_mssql_virtual_network_rule" "test" {
  name      = "acctestsqlvnetrule240119025436790900"
  server_id = azurerm_mssql_server.test.id
  subnet_id = azurerm_subnet.test2.id
}
