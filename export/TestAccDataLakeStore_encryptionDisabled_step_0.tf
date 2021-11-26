
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211126031113702450"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest112603111370245"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
