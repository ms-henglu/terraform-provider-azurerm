
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221202040304537284"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw221202040304537284"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
