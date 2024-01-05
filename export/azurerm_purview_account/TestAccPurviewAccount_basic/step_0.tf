
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-240105064447583130"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw240105064447583130"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
