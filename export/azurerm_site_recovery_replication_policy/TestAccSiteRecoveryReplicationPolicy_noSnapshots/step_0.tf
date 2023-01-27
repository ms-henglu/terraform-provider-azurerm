
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-230127045945093363"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-230127045945093363"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_replication_policy" "test" {
  resource_group_name                                  = azurerm_resource_group.test.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.test.name
  name                                                 = "acctest-policy-230127045945093363"
  recovery_point_retention_in_minutes                  = 2880
  application_consistent_snapshot_frequency_in_minutes = 0
}
