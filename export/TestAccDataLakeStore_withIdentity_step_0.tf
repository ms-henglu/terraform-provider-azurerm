
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220114014124379067"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest011401412437906"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
