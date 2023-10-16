

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-231016034326095029"
  location = "West Europe"
}


resource "azurerm_monitor_action_rule_suppression" "test" {
  name                = "acctest-moniter-231016034326095029"
  resource_group_name = azurerm_resource_group.test.name

  scope {
    type         = "ResourceGroup"
    resource_ids = [azurerm_resource_group.test.id]
  }

  suppression {
    recurrence_type = "Daily"

    schedule {
      start_date_utc = "2019-01-01T01:02:03Z"
      end_date_utc   = "2019-01-03T15:02:07Z"
    }
  }
}
