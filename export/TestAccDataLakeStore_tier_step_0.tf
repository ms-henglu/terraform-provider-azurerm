
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211105025905708339"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest110502590570833"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
