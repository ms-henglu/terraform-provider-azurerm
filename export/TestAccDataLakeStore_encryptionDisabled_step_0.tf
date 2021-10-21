
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211021234917123300"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest102123491712330"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
