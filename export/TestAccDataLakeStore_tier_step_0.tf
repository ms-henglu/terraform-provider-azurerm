
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211001223910963393"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest100122391096339"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
