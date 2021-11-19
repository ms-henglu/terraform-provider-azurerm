
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211119050741598904"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest111905074159890"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
