

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-240311031904965965"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-240311031904965965"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "test" {
  name                = "acctest-aks-240311031904965965"
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
      duration        = "P7D"
      data_store_type = "OperationalStore"
    }
  }
}
