
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-230421021622190121"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230421021622190121"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_app_configuration" "test" {
  name                  = "testaccappconf230421021622190121"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  public_network_access = "Disabled"
  sku                   = "standard"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  tags = {
    ENVironment = "DEVelopment"
  }
}
