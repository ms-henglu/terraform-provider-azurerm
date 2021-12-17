

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211217035725233773"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw211217035725233773"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
