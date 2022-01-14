


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dbms-220114014053539554"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVnet-dbms-220114014053539554"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestSubnet-dbms-220114014053539554"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
}


resource "azurerm_database_migration_service" "test" {
  name                = "acctestDbms-220114014053539554"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  subnet_id           = azurerm_subnet.test.id
  sku_name            = "Standard_1vCores"
}


resource "azurerm_database_migration_project" "test" {
  name                = "acctestDbmsProject-220114014053539554"
  service_name        = azurerm_database_migration_service.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  source_platform     = "SQL"
  target_platform     = "SQLDB"
  tags = {
    name = "Test"
  }
}
