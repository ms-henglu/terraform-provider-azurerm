

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-backup-230804030554414872"
  location = "West Europe"
}

resource "azurerm_storage_account" "test1" {
  name                     = "acctestu3c6b1"
  location                 = "${azurerm_resource_group.test.location}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctestu3c6b2"
  location                 = "${azurerm_resource_group.test.location}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "testshare1" {
  name                 = "acctest-ss-230804030554414872-1"
  storage_account_name = "${azurerm_storage_account.test1.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_storage_share" "testshare2" {
  name                 = "acctest-ss-230804030554414872-2"
  storage_account_name = "${azurerm_storage_account.test1.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_storage_share" "testshare3" {
  name                 = "acctest-ss-230804030554414872-1"
  storage_account_name = "${azurerm_storage_account.test2.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_storage_share" "testshare4" {
  name                 = "acctest-ss-230804030554414872-2"
  storage_account_name = "${azurerm_storage_account.test2.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-VAULT-230804030554414872"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"

  soft_delete_enabled = true
}

resource "azurerm_backup_policy_file_share" "test" {
  name                = "acctest-PFS-230804030554414872"
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


resource "azurerm_backup_container_storage_account" "test1" {
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name
  storage_account_id  = azurerm_storage_account.test1.id
}

resource "azurerm_backup_container_storage_account" "test2" {
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name
  storage_account_id  = azurerm_storage_account.test2.id
}

resource "azurerm_backup_protected_file_share" "test" {
  resource_group_name       = azurerm_resource_group.test.name
  recovery_vault_name       = azurerm_recovery_services_vault.test.name
  source_storage_account_id = azurerm_backup_container_storage_account.test2.storage_account_id
  source_file_share_name    = azurerm_storage_share.testshare3.name
  backup_policy_id          = azurerm_backup_policy_file_share.test.id
}

resource "azurerm_storage_share" "testshare" {
  name                 = "acctest-ss-230804030554414872"
  storage_account_name = "${azurerm_storage_account.test2.name}"
  quota                = 1
  metadata             = {}

  lifecycle {
    ignore_changes = [metadata] // Ignore changes Azure Backup makes to the metadata
  }
}

resource "azurerm_backup_protected_file_share" "test1" {
  resource_group_name       = azurerm_resource_group.test.name
  recovery_vault_name       = azurerm_recovery_services_vault.test.name
  source_storage_account_id = azurerm_backup_container_storage_account.test2.storage_account_id
  source_file_share_name    = azurerm_storage_share.testshare.name
  backup_policy_id          = azurerm_backup_policy_file_share.test.id
}
