
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220124124953518400"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest012412495351840"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
