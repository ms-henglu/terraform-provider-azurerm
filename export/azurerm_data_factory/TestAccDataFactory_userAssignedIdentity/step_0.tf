
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221111013423835079"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest221111013423835079"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_factory" "test" {
  name                = "acctest221111013423835079"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }
}
