
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211013071751259489"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest101307175125948"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
