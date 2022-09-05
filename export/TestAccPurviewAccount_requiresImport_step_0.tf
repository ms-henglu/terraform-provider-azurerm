
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220905050340064248"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220905050340064248"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
