
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211217075142513641"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121707514251364"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
