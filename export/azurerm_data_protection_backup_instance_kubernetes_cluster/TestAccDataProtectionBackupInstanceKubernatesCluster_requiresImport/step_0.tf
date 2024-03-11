

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dp-240311031904960931"
  location = "West Europe"
}

resource "azurerm_resource_group" "snap" {
  name     = "acctest-dp-snap-240311031904960931"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-240311031904960931"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  soft_delete         = "Off"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240311031904960931"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240311031904960931"

  default_node_pool {
    name                   = "default"
    node_count             = 1
    vm_size                = "Standard_DS2_v2"
    enable_host_encryption = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "test_aks_cluster_trusted_access" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  name                  = "mayankta"
  roles                 = ["Microsoft.DataProtection/backupVaults/backup-operator"]
  source_resource_id    = azurerm_data_protection_backup_vault.test.id
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestfl9yg"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "testaccscfl9yg"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_kubernetes_cluster_extension" "test" {
  name              = "acctest-kce-240311031904960931"
  cluster_id        = azurerm_kubernetes_cluster.test.id
  extension_type    = "Microsoft.DataProtection.Kubernetes"
  release_train     = "stable"
  release_namespace = "dataprotection-microsoft"
  configuration_settings = {
    "configuration.backupStorageLocation.bucket"                = azurerm_storage_container.test.name
    "configuration.backupStorageLocation.config.resourceGroup"  = azurerm_resource_group.test.name
    "configuration.backupStorageLocation.config.storageAccount" = azurerm_storage_account.test.name
    "configuration.backupStorageLocation.config.subscriptionId" = data.azurerm_client_config.current.subscription_id
    "credentials.tenantId"                                      = data.azurerm_client_config.current.tenant_id
  }
}

resource "azurerm_role_assignment" "test_extension_and_storage_account_permission" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.test.aks_assigned_identity[0].principal_id
}

resource "azurerm_role_assignment" "test_vault_msi_read_on_cluster" {
  scope                = azurerm_kubernetes_cluster.test.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.test.identity[0].principal_id
}

resource "azurerm_role_assignment" "test_vault_msi_read_on_snap_rg" {
  scope                = azurerm_resource_group.snap.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.test.identity[0].principal_id
}

resource "azurerm_role_assignment" "test_cluster_msi_contributor_on_snap_rg" {
  scope                = azurerm_resource_group.snap.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.test.identity[0].principal_id
}

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "test" {
  name                = "acctest-paks-240311031904960931"
  resource_group_name = azurerm_resource_group.test.name
  vault_name          = azurerm_data_protection_backup_vault.test.name

  backup_repeating_time_intervals = ["R/2021-05-23T02:30:00+00:00/P1W"]

  retention_rule {
    name     = "Daily"
    priority = 25

    life_cycle {
      duration        = "P84D"
      data_store_type = "OperationalStore"
    }

    criteria {
      days_of_week           = ["Thursday"]
      months_of_year         = ["November"]
      weeks_of_month         = ["First"]
      scheduled_backup_times = ["2021-05-23T02:30:00Z"]
    }
  }

  default_retention_rule {
    life_cycle {
      duration        = "P14D"
      data_store_type = "OperationalStore"
    }
  }
}



resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "test" {
  name                         = "acctest-iaks-240311031904960931"
  location                     = azurerm_resource_group.test.location
  vault_id                     = azurerm_data_protection_backup_vault.test.id
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.test.id
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.test.id
  snapshot_resource_group_name = azurerm_resource_group.snap.name
}
