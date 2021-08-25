

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-210825045138033109"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw210825045138033109"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Standard_4"
}
