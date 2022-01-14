
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220114064037611426"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest011406403761142"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
