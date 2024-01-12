
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-240112035029908613"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-240112035029908613"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_hyperv_replication_policy" "test" {
  recovery_vault_id                                  = azurerm_recovery_services_vault.test.id
  name                                               = "acctest-policy-240112035029908613"
  recovery_point_retention_in_hours                  = 2
  application_consistent_snapshot_frequency_in_hours = 1
  replication_interval_in_seconds                    = 300
}
