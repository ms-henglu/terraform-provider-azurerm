

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dbms-211015014507259264"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVnet-dbms-211015014507259264"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestSubnet-dbms-211015014507259264"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
}


resource "azurerm_database_migration_service" "test" {
  name                = "acctestDbms-211015014507259264"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test.id
  sku_name            = "Standard_1vCores"
}
