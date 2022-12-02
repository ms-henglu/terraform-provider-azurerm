

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-backup-221202040308933422"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-221202040308933422"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false
}


resource "azurerm_backup_policy_vm" "test" {
  name                           = "acctest-BPVM-221202040308933422"
  resource_group_name            = azurerm_resource_group.test.name
  recovery_vault_name            = azurerm_recovery_services_vault.test.name
  instant_restore_retention_days = 1
  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 31
  }

  policy_type = "V1"
}
