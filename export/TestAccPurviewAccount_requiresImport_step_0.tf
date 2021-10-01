

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211001054106855318"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw211001054106855318"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Standard_4"
}
