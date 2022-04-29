
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065809590528"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesta6d2t"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
