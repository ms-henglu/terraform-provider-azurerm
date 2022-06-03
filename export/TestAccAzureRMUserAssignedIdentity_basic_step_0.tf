
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603022402712168"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestq3c23"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
