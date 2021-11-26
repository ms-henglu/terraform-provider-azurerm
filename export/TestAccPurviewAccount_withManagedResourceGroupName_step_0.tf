

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-211126031545744070"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw211126031545744070"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-211126031545744070"
}
