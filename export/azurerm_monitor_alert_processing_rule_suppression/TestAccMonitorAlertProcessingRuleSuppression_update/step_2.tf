

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-maprs-231016034326105818"
  location = "West Europe"
}


resource "azurerm_monitor_alert_processing_rule_suppression" "test" {
  name                = "acctest-moniter-231016034326105818"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]
  enabled             = false

  condition {
    signal_type {
      operator = "NotEquals"
      values   = ["Health"]
    }
  }

  schedule {
    recurrence {
      weekly {
        days_of_week = ["Monday"]
      }
    }
  }

  tags = {
    ENV = "Test"
  }
}




