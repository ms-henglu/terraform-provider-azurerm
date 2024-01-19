
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025804609756"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-240119025804609756"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-240119025804609756"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
