

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211119051306470042"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw211119051306470042"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-211119051306470042"
}
