
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-231013044116290607"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw231013044116290607"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
