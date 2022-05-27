
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220527034551817244"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220527034551817244"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
