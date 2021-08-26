
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210826023304531674"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082602330453167"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
