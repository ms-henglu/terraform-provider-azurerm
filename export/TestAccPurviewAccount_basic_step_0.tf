

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-210928075823054829"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw210928075823054829"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Standard_4"
}
