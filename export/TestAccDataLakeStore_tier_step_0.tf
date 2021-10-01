
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211001020710346377"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest100102071034637"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
