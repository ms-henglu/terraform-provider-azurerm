
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210924004148243884"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest092400414824388"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
