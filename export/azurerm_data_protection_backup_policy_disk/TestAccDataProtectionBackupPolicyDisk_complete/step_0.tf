

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230428045611649558"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-230428045611649558"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}

resource "azurerm_data_protection_backup_policy_disk" "test" {
  name                            = "acctest-dbp-230428045611649558"
  vault_id                        = azurerm_data_protection_backup_vault.test.id
  backup_repeating_time_intervals = ["R/2021-05-19T06:33:16+00:00/PT4H"]
  default_retention_duration      = "P7D"

  retention_rule {
    name     = "Daily"
    duration = "P7D"
    priority = 25
    criteria {
      absolute_criteria = "FirstOfDay"
    }
  }

  retention_rule {
    name     = "Weekly"
    duration = "P7D"
    priority = 20
    criteria {
      absolute_criteria = "FirstOfWeek"
    }
  }
}
