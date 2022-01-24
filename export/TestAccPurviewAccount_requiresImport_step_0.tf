

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220124122524141167"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220124122524141167"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
