
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211105035803886120"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest110503580388612"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
