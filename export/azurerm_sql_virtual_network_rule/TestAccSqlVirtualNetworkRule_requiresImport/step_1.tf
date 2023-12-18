

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072614101893"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet231218072614101893"
  address_space       = ["10.7.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet231218072614101893"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver231218072614101893"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadmin"
  administrator_login_password = "${md5(231218072614101893)}!"
}

resource "azurerm_sql_virtual_network_rule" "test" {
  name                                 = "acctestsqlvnetrule231218072614101893"
  resource_group_name                  = azurerm_resource_group.test.name
  server_name                          = azurerm_sql_server.test.name
  subnet_id                            = azurerm_subnet.test.id
  ignore_missing_vnet_service_endpoint = false
}


resource "azurerm_sql_virtual_network_rule" "import" {
  name                                 = azurerm_sql_virtual_network_rule.test.name
  resource_group_name                  = azurerm_sql_virtual_network_rule.test.resource_group_name
  server_name                          = azurerm_sql_virtual_network_rule.test.server_name
  subnet_id                            = azurerm_sql_virtual_network_rule.test.subnet_id
  ignore_missing_vnet_service_endpoint = azurerm_sql_virtual_network_rule.test.ignore_missing_vnet_service_endpoint
}
