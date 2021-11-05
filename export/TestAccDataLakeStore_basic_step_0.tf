
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211105035803884564"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest110503580388456"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
