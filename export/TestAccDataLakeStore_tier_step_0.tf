
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220107063920583995"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest010706392058399"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
