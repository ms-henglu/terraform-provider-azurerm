
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210924010911483610"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest092401091148361"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
