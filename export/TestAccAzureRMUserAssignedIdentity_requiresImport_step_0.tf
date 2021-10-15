
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014906055297"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuktiw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
