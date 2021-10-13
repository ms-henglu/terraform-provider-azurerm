
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072142519228"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestlb06x"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
