
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-backup-230106034928045436"
  location = "West Europe"
}

resource "azurerm_storage_account" "test1" {
  name                     = "acctesto18wv1"
  location                 = "${azurerm_resource_group.test.location}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctesto18wv2"
  location                 = "${azurerm_resource_group.test.location}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "testshare1" {
  name                 = "acctest-ss-230106034928045436-1"
  storage_account_name = "${azurerm_storage_account.test1.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_storage_share" "testshare2" {
  name                 = "acctest-ss-230106034928045436-2"
  storage_account_name = "${azurerm_storage_account.test1.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_storage_share" "testshare3" {
  name                 = "acctest-ss-230106034928045436-1"
  storage_account_name = "${azurerm_storage_account.test2.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_storage_share" "testshare4" {
  name                 = "acctest-ss-230106034928045436-2"
  storage_account_name = "${azurerm_storage_account.test2.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-VAULT-230106034928045436"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"

  soft_delete_enabled = true
}

resource "azurerm_backup_policy_file_share" "test" {
  name                = "acctest-PFS-230106034928045436"
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
