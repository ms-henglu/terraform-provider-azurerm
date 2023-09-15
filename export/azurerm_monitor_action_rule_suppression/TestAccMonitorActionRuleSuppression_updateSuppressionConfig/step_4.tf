

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-230915023817049680"
  location = "West Europe"
}


resource "azurerm_monitor_action_rule_suppression" "test" {
  name                = "acctest-moniter-230915023817049680"
  resource_group_name = azurerm_resource_group.test.name

  scope {
    type         = "ResourceGroup"
    resource_ids = [azurerm_resource_group.test.id]
  }

  suppression {
    recurrence_type = "Monthly"

    schedule {
      start_date_utc     = "2019-01-01T01:02:03Z"
      end_date_utc       = "2019-01-03T15:02:07Z"
      recurrence_monthly = [1, 2, 15, 30, 31]
    }
  }
}
