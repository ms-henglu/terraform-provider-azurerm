
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211203013711131284"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest120301371113128"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
