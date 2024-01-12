
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-240112035021089402"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw240112035021089402"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
