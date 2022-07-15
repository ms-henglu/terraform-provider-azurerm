
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715014757690652"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestqbs2f"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
