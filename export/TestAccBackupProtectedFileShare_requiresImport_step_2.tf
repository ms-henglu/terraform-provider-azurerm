
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-backup-210928075830563303"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestz1qcz"
  location                 = "${azurerm_resource_group.test.location}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "acctest-ss-210928075830563303"
  storage_account_name = "${azurerm_storage_account.test.name}"
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-VAULT-210928075830563303"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"

  soft_delete_enabled = true
}

resource "azurerm_backup_policy_file_share" "test1" {
  name                = "acctest-PFS-210928075830563303"
  resource_group_name = "${azurerm_resource_group.test.name}"
  recovery_vault_name = "${azurerm_recovery_services_vault.test.name}"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }
}
