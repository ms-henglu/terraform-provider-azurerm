
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211008044315412138"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest100804431541213"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
