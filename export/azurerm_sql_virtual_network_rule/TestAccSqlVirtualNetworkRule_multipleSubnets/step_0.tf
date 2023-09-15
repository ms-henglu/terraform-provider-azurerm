
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024243317521"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "acctestvnet1230915024243317521"
  address_space       = ["10.7.29.0/24"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "acctestvnet2230915024243317521"
  address_space       = ["10.1.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "vnet1_subnet1" {
  name                 = "acctestsubnet1230915024243317521"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "vnet1_subnet2" {
  name                 = "acctestsubnet2230915024243317521"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.7.29.128/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "vnet2_subnet1" {
  name                 = "acctestsubnet3230915024243317521"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.1.29.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver1230915024243317521"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadmin"
  administrator_login_password = "${md5(230915024243317521)}!"
}

resource "azurerm_sql_virtual_network_rule" "test" {
  name                                 = "acctestsqlvnetrule1230915024243317521"
  resource_group_name                  = azurerm_resource_group.test.name
  server_name                          = azurerm_sql_server.test.name
  subnet_id                            = azurerm_subnet.vnet1_subnet1.id
  ignore_missing_vnet_service_endpoint = false
}

resource "azurerm_sql_virtual_network_rule" "rule2" {
  name                                 = "acctestsqlvnetrule2230915024243317521"
  resource_group_name                  = azurerm_resource_group.test.name
  server_name                          = azurerm_sql_server.test.name
  subnet_id                            = azurerm_subnet.vnet1_subnet2.id
  ignore_missing_vnet_service_endpoint = false
}

resource "azurerm_sql_virtual_network_rule" "rule3" {
  name                                 = "acctestsqlvnetrule3230915024243317521"
  resource_group_name                  = azurerm_resource_group.test.name
  server_name                          = azurerm_sql_server.test.name
  subnet_id                            = azurerm_subnet.vnet2_subnet1.id
  ignore_missing_vnet_service_endpoint = false
}
