
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230519075452182074"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230519075452182074"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
