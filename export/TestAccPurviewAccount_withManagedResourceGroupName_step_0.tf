

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211217075713154600"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw211217075713154600"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-211217075713154600"
}
