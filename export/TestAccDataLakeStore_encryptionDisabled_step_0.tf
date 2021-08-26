
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210826023304532098"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082602330453209"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
