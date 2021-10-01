
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001053645643938"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet211001053645643938"
  address_space       = ["10.7.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet211001053645643938"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.AzureActiveDirectory"]
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctestadls10010536456"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_store_virtual_network_rule" "test" {
  name                = "acctestadlsvnetrule211001053645643938"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_data_lake_store.test.name
  subnet_id           = azurerm_subnet.test.id
}
