
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210906022156878182"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest090602215687818"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
