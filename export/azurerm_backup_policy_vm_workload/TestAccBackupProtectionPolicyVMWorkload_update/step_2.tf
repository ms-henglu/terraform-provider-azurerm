
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-bpvmw-230915024052085368"
  location = "West Europe"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-rsv-230915024052085368"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  soft_delete_enabled = false
}

resource "azurerm_backup_policy_vm_workload" "test" {
  name                = "acctest-bpvmw-230915024052085368"
  resource_group_name = azurerm_resource_group.test.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name

  workload_type = "SAPHanaDatabase"

  settings {
    time_zone           = "Pacific Standard Time"
    compression_enabled = false
  }

  protection_policy {
    policy_type = "Full"

    backup {
      frequency = "Weekly"
      time      = "16:00"
      weekdays  = ["Tuesday", "Thursday"]
    }

    retention_weekly {
      weekdays = ["Tuesday", "Thursday"]
      count    = 5
    }

    retention_monthly {
      format_type = "Weekly"
      weeks       = ["Third", "First"]
      weekdays    = ["Tuesday", "Thursday"]
      count       = 11
    }

    retention_yearly {
      format_type = "Weekly"
      months      = ["July", "February"]
      weeks       = ["Third", "First"]
      weekdays    = ["Tuesday", "Thursday"]
      count       = 9
    }
  }

  protection_policy {
    policy_type = "Differential"

    backup {
      frequency = "Weekly"
      weekdays  = ["Saturday", "Sunday"]
      time      = "17:00"
    }

    simple_retention {
      count = 12
    }
  }

  protection_policy {
    policy_type = "Log"

    backup {
      frequency_in_minutes = 30
    }

    simple_retention {
      count = 9
    }
  }
}
