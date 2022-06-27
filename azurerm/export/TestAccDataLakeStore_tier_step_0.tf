
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220627122600783992"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest062712260078399"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
