
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221111013423838170"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest221111013423838170"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_factory" "test" {
  name                = "acctest221111013423838170"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }
}
