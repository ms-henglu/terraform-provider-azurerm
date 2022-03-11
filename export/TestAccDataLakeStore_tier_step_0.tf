
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220311042303954901"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest031104230395490"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
