
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230120052559844293"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230120052559844293"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
