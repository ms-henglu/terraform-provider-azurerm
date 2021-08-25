
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825044708919586"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet210825044708919586"
  address_space       = ["10.7.29.0/24"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test1" {
  name                 = "subnet1210825044708919586"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/25"]
  service_endpoints    = ["Microsoft.AzureActiveDirectory"]
}

resource "azurerm_subnet" "test2" {
  name                 = "subnet2210825044708919586"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.128/25"]
  service_endpoints    = ["Microsoft.AzureActiveDirectory"]
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctestadls08250447089"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_store_virtual_network_rule" "test" {
  name                = "acctestadlsvnetrule210825044708919586"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_data_lake_store.test.name
  subnet_id           = azurerm_subnet.test2.id
}
