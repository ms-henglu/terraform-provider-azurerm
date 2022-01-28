

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220128052934793422"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220128052934793422"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
