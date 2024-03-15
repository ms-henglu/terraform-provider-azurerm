

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-240315122834734479"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-240315122834734479"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "test" {
  name                            = "acctest-aks-240315122834734479"
  resource_group_name             = azurerm_resource_group.test.name
  vault_name                      = azurerm_data_protection_backup_vault.test.name
  backup_repeating_time_intervals = ["R/2021-05-23T02:30:00+00:00/P1W"]
  time_zone                       = "India Standard Time"

  retention_rule {
    name     = "Daily"
    priority = 25

    life_cycle {
      duration        = "P7D"
      data_store_type = "OperationalStore"
    }

    life_cycle {
      duration        = "P84D"
      data_store_type = "OperationalStore"
    }

    criteria {
      absolute_criteria = "FirstOfDay"
    }
  }

  default_retention_rule {
    life_cycle {
      duration        = "P7D"
      data_store_type = "OperationalStore"
    }
  }
}
