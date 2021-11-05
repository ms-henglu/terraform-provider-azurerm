

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211105040335123120"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw211105040335123120"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
