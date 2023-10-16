
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-231016034552452402"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw231016034552452402"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
