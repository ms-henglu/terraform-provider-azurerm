
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-231218072415582456"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw231218072415582456"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
