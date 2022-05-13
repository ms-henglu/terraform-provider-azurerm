
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-220513180707189665"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-220513180707189665"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_replication_policy" "test" {
  resource_group_name                                  = azurerm_resource_group.test.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.test.name
  name                                                 = "acctest-policy-220513180707189665"
  recovery_point_retention_in_minutes                  = 1440
  application_consistent_snapshot_frequency_in_minutes = 240
}
