
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-221021031635397396"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw221021031635397396"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
