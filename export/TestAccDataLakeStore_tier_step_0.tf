
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211029015500790882"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest102901550079088"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
