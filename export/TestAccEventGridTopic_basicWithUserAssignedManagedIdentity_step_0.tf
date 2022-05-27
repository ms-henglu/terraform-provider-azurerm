
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034150259929"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesteg-220527034150259929"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220527034150259929"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }
}
