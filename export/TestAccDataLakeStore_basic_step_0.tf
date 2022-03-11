
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220311032342257191"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest031103234225719"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
