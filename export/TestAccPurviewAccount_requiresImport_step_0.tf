
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220923012229378375"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220923012229378375"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
