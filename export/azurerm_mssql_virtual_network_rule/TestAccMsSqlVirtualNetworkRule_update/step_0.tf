

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085528875890"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet230526085528875890"
  address_space       = ["10.7.28.0/23"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test1" {
  name                 = "subnet1230526085528875890"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.28.0/25"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "test2" {
  name                 = "subnet2230526085528875890"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.28.128/25"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "test3" {
  name                 = "subnet3230526085528875890"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/25"]
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230526085528875890"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadmin"
  administrator_login_password = "P@55W0rD!!nvbj3"
}


resource "azurerm_mssql_virtual_network_rule" "test" {
  name      = "acctestsqlvnetrule230526085528875890"
  server_id = azurerm_mssql_server.test.id
  subnet_id = azurerm_subnet.test1.id
}
