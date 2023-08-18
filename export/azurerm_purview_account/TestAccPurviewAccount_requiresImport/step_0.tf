
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230818024640152887"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230818024640152887"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
