
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211008044315418342"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest100804431541834"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
