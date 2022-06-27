
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220627131655100474"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220627131655100474"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
