
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230804030542158354"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230804030542158354"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
