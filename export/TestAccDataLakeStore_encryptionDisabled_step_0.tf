
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220311032342256601"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest031103234225660"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
