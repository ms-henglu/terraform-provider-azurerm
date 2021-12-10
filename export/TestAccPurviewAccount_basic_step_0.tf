

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211210024937802076"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw211210024937802076"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
