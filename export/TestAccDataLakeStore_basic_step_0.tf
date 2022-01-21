
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220121044420388718"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest012104442038871"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
