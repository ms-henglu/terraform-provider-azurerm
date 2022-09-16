
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220916011243729407"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220916011243729407"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  name = "testaccuai220916011243729407"
}
