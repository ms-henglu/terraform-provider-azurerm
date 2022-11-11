

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221111013659246972"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-221111013659246972"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-8edat"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
