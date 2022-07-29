
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220729033029251516"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestnc2hg"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
