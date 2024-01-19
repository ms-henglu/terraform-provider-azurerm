
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119024528961274"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-240119024528961274"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  backup {
    policy_name                        = "acctest-backup-policy-240119024528961274"
    time_zone                          = "UTC"
    instant_rp_retention_range_in_days = 2

    schedule_policy {
      schedule_run_frequency = "Daily"
      schedule_run_days      = ["Monday", "Tuesday"]
      schedule_run_times     = ["12:00"]
      schedule_policy_type   = "SimpleSchedulePolicy"
    }

    retention_policy {
      retention_policy_type = "LongTermRetentionPolicy"

      daily_schedule {
        retention_times = ["12:00"]
        retention_duration {
          count         = 7
          duration_type = "Days"
        }
      }

      weekly_schedule {
        retention_times = ["14:00"]
        retention_duration {
          count         = 4
          duration_type = "Weeks"
        }
      }
    }
  }
}
