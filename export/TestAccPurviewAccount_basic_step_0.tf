

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211105030426539473"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw211105030426539473"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
