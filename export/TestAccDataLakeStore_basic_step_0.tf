
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220311042303959917"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest031104230395991"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
