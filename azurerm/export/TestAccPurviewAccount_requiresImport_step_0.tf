

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220627132247469999"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220627132247469999"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Standard_4"
}
