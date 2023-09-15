
provider "azurerm" {
  features {}
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-uai-230915024052096699"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-230915024052096699"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-Vault-230915024052096699"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  soft_delete_enabled = false
}
