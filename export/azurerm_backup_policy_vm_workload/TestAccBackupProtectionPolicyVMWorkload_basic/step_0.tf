
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-bpvmw-230915024052080341"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-rsv-230915024052080341"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  soft_delete_enabled = false
}

resource "azurerm_backup_policy_vm_workload" "test" {
  name                = "acctest-bpvmw-230915024052080341"
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name

  workload_type = "SQLDataBase"

  settings {
    time_zone           = "UTC"
    compression_enabled = false
  }

  protection_policy {
    policy_type = "Full"

    backup {
      frequency = "Daily"
      time      = "15:00"
    }

    retention_daily {
      count = 8
    }

    retention_monthly {
      format_type = "Daily"
      count       = 10
      monthdays   = [27, 28]
    }

    retention_yearly {
      format_type = "Daily"
      count       = 10
      months      = ["February"]
      monthdays   = [27, 28]
    }
  }

  protection_policy {
    policy_type = "Log"

    backup {
      frequency_in_minutes = 15
    }

    simple_retention {
      count = 8
    }
  }
}
