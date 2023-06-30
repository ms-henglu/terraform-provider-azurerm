
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-230630033809177116"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw230630033809177116"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
