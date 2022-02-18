
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220218070641461048"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest021807064146104"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
