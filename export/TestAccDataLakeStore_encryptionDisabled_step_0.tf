
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211112020512512544"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest111202051251254"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
