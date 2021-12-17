
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035151686695"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "acctestvnet1211217035151686695"
  address_space       = ["10.7.29.0/24"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "acctestvnet2211217035151686695"
  address_space       = ["10.1.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "vnet1_subnet1" {
  name                 = "acctestsubnet1211217035151686695"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.AzureActiveDirectory"]
}

resource "azurerm_subnet" "vnet1_subnet2" {
  name                 = "acctestsubnet2211217035151686695"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.7.29.128/29"]
  service_endpoints    = ["Microsoft.AzureActiveDirectory"]
}

resource "azurerm_subnet" "vnet2_subnet1" {
  name                 = "acctestsubnet3211217035151686695"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.1.29.0/29"]
  service_endpoints    = ["Microsoft.AzureActiveDirectory"]
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctestadls12170351516"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_store_virtual_network_rule" "test" {
  name                = "acctestsqlvnetrule1211217035151686695"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_data_lake_store.test.name
  subnet_id           = azurerm_subnet.vnet1_subnet1.id
}

resource "azurerm_data_lake_store_virtual_network_rule" "rule2" {
  name                = "acctestsqlvnetrule2211217035151686695"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_data_lake_store.test.name
  subnet_id           = azurerm_subnet.vnet1_subnet2.id
}

resource "azurerm_data_lake_store_virtual_network_rule" "rule3" {
  name                = "acctestsqlvnetrule3211217035151686695"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_data_lake_store.test.name
  subnet_id           = azurerm_subnet.vnet2_subnet1.id
}
