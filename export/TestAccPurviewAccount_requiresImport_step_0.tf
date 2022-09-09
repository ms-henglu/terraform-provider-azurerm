
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220909034835230708"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220909034835230708"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
