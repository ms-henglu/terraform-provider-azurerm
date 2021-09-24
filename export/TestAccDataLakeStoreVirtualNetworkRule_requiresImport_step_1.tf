

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004148247861"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet210924004148247861"
  address_space       = ["10.7.29.0/29"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet210924004148247861"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.AzureActiveDirectory"]
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctestadls09240041482"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_store_virtual_network_rule" "test" {
  name                = "acctestadlsvnetrule210924004148247861"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_data_lake_store.test.name
  subnet_id           = azurerm_subnet.test.id
}


resource "azurerm_data_lake_store_virtual_network_rule" "import" {
  name                = azurerm_data_lake_store_virtual_network_rule.test.name
  resource_group_name = azurerm_data_lake_store_virtual_network_rule.test.resource_group_name
  account_name        = azurerm_data_lake_store_virtual_network_rule.test.account_name
  subnet_id           = azurerm_data_lake_store_virtual_network_rule.test.subnet_id
}
