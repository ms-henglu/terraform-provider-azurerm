
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220211043507756972"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest021104350775697"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
