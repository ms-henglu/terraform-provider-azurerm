

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211203161757104192"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw211203161757104192"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-211203161757104192"
}
