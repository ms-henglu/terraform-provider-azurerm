
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210825040721843485"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082504072184348"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
