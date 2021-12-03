

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211203014302667700"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw211203014302667700"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
