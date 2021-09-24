
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210924004148243159"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest092400414824315"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
