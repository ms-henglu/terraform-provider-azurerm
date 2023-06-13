
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230613071350413657"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-230613071350413657"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  backup {
    policy_name                        = "acctest-backup-policy-230613071350413657"
    time_zone                          = "UTC"
    instant_rp_retention_range_in_days = 5

    schedule_policy {
      schedule_run_frequency = "Daily"
      schedule_run_days      = ["Monday"]
      schedule_run_times     = ["12:00"]
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
    }
  }
}
