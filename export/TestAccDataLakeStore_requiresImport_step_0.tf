
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211022001901281516"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest102200190128151"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
