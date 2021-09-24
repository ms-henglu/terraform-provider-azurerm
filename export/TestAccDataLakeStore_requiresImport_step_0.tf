
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210924010911487320"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest092401091148732"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
