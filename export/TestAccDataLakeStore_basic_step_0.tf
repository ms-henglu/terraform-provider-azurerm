
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210825025719453643"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082502571945364"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
