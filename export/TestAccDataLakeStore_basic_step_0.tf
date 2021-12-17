
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211217035151679624"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121703515167962"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
