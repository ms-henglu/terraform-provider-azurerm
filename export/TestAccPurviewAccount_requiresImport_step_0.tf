
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220722052408179464"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220722052408179464"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
