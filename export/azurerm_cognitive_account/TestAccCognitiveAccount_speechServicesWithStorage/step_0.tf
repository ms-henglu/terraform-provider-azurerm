
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230915023022270751"
  location = "West US 2"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestrg23091551"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-identity-230915023022270751"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-230915023022270751"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "SpeechServices"
  sku_name            = "S0"

  identity {
    type = "SystemAssigned"
  }

  storage {
    storage_account_id = azurerm_storage_account.test.id
    identity_client_id = azurerm_user_assigned_identity.test.client_id
  }
}
