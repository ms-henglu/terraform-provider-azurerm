
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210917031601581068"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest091703160158106"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
