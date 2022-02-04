
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204093311328669"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest0txlv"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
