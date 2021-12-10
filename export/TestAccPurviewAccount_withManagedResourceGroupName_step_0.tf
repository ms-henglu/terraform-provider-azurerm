

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211210035227163257"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw211210035227163257"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-211210035227163257"
}
