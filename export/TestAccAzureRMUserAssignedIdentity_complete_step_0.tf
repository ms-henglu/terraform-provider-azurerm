
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034441646373"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestdfzyh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
