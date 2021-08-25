
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210825025719454614"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082502571945461"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
