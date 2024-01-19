
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-240119025700990644"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-240119025700990644"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_vmware_replication_policy" "test" {
  recovery_vault_id                                    = azurerm_recovery_services_vault.test.id
  name                                                 = "acctest-policy-240119025700990644"
  recovery_point_retention_in_minutes                  = 2880
  application_consistent_snapshot_frequency_in_minutes = 0
}
