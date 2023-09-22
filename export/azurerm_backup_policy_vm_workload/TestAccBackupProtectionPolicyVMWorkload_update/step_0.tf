
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-bpvmw-230922054753889176"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-rsv-230922054753889176"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  soft_delete_enabled = false
}

resource "azurerm_backup_policy_vm_workload" "test" {
  name                = "acctest-bpvmw-230922054753889176"
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name

  workload_type = "SAPHanaDatabase"

  settings {
    time_zone           = "UTC"
    compression_enabled = true
  }

  protection_policy {
    policy_type = "Full"

    backup {
      frequency = "Weekly"
      time      = "15:00"
      weekdays  = ["Monday", "Tuesday"]
    }

    retention_weekly {
      weekdays = ["Monday", "Tuesday"]
      count    = 4
    }

    retention_monthly {
      format_type = "Weekly"
      weeks       = ["Third"]
      weekdays    = ["Tuesday"]
      count       = 10
    }

    retention_yearly {
      format_type = "Weekly"
      months      = ["May", "February"]
      weeks       = ["Third"]
      weekdays    = ["Tuesday"]
      count       = 8
    }
  }

  protection_policy {
    policy_type = "Incremental"

    backup {
      frequency = "Weekly"
      weekdays  = ["Saturday", "Friday"]
      time      = "23:00"
    }

    simple_retention {
      count = 11
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
