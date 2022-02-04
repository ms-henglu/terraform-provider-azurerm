
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220204092903550143"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctestw2q42"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_type     = "ServiceManaged"
}
