

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-210830084353068589"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw210830084353068589"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Standard_4"
}
