
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220630224043720803"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220630224043720803"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
