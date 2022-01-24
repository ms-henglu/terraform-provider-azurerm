
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220124124953516868"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest012412495351686"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
