
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210910021319997761"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest091002131999776"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
