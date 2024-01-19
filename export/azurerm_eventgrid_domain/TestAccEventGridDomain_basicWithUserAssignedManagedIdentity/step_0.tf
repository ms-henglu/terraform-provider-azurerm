
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025027110005"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctesteg-240119025027110005"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-240119025027110005"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }
}
