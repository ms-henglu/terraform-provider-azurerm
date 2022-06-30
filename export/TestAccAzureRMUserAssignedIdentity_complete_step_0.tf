
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630211116207409"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "accteste8wiw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = "test"
  }
}
