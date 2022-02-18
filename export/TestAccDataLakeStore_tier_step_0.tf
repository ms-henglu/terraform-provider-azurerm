
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220218070641462414"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest021807064146241"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
