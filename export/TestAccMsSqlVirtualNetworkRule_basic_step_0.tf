

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014537539135"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet211015014537539135"
  address_space       = ["10.7.28.0/23"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test1" {
  name                 = "subnet1211015014537539135"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.7.28.0/25"
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "test2" {
  name                 = "subnet2211015014537539135"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.7.28.128/25"
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "test3" {
  name                 = "subnet3211015014537539135"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.7.29.0/25"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver211015014537539135"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadmin"
  administrator_login_password = "P@55W0rD!!t7b3q"
}


resource "azurerm_mssql_virtual_network_rule" "test" {
  name      = "acctestsqlvnetrule211015014537539135"
  server_id = azurerm_mssql_server.test.id
  subnet_id = azurerm_subnet.test1.id
}
