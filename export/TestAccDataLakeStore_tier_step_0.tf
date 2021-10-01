
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211001053645645461"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest100105364564546"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
