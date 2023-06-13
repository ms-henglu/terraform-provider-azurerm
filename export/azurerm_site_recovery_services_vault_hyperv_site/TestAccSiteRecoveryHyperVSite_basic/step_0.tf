
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-230613072507275980"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-230613072507275980"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_services_vault_hyperv_site" "test" {
  recovery_vault_id = azurerm_recovery_services_vault.test.id
  name              = "acctest-site-230613072507275980"
}
