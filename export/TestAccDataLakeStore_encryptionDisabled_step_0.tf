
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220107033807090960"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest010703380709096"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
