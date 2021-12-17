
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211217035151687240"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121703515168724"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
