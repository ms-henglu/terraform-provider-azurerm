


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211015014649839461"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw211015014649839461"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Standard_4"
}


resource "azurerm_purview_account" "import" {
  name                = azurerm_purview_account.test.name
  resource_group_name = azurerm_purview_account.test.resource_group_name
  location            = azurerm_purview_account.test.location
  sku_name            = azurerm_purview_account.test.sku_name
}
