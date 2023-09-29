

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230929064744482221"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-230929064744482221"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_postgresql" "test" {
  name                = "acctest-dbp-230929064744482221"
  resource_group_name = azurerm_resource_group.test.name
  vault_name          = azurerm_data_protection_backup_vault.test.name

  backup_repeating_time_intervals = ["R/2021-05-23T02:30:00+00:00/P1W"]
  default_retention_duration      = "P4M"
  retention_rule {
    name     = "weekly"
    duration = "P6M"
    priority = 20
    criteria {
      absolute_criteria = "FirstOfWeek"
    }
  }

  retention_rule {
    name     = "thursday"
    duration = "P1W"
    priority = 25
    criteria {
      days_of_week           = ["Thursday"]
      months_of_year         = ["November"]
      scheduled_backup_times = ["2021-05-23T02:30:00Z"]
    }
  }

  retention_rule {
    name     = "monthly"
    duration = "P1D"
    priority = 30
    criteria {
      weeks_of_month         = ["First", "Last"]
      days_of_week           = ["Tuesday"]
      scheduled_backup_times = ["2021-05-23T02:30:00Z"]
    }
  }
}
