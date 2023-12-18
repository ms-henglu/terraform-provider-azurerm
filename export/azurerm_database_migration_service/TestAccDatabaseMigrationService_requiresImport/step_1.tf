


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dbms-231218071547844530"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVnet-dbms-231218071547844530"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestSubnet-dbms-231218071547844530"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_database_migration_service" "test" {
  name                = "acctestDbms-231218071547844530"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test.id
  sku_name            = "Standard_1vCores"
}


resource "azurerm_database_migration_service" "import" {
  name                = azurerm_database_migration_service.test.name
  location            = azurerm_database_migration_service.test.location
  resource_group_name = azurerm_database_migration_service.test.resource_group_name
  subnet_id           = azurerm_database_migration_service.test.subnet_id
  sku_name            = azurerm_database_migration_service.test.sku_name
}
