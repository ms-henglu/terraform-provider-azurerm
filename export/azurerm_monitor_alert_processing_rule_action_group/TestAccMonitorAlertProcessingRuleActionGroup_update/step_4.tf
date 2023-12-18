

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-monitor-maprag-231218072152343298"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-231218072152343298"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctest-ag"
}


resource "azurerm_monitor_alert_processing_rule_action_group" "test" {
  name                 = "acctest-moniter-231218072152343298"
  resource_group_name  = azurerm_resource_group.test.name
  description          = "alertprocessingrule-test"
  add_action_group_ids = [azurerm_monitor_action_group.test.id]
  scopes               = [azurerm_resource_group.test.id]
  enabled              = false

  condition {
    alert_context {
      operator = "Contains"
      values   = ["context1", "context2"]
    }

    alert_rule_id {
      operator = "Contains"
      values   = ["ruleId1", "ruleId2"]
    }

    alert_rule_name {
      operator = "DoesNotContain"
      values   = ["ruleName1", "ruleName2"]
    }

    description {
      operator = "DoesNotContain"
      values   = ["description1", "description2"]
    }

    monitor_condition {
      operator = "NotEquals"
      values   = ["Fired"]
    }

    monitor_service {
      operator = "Equals"
      values   = ["Data Box Gateway", "Resource Health", "Prometheus"]
    }

    severity {
      operator = "Equals"
      values   = ["Sev0", "Sev1", "Sev2"]
    }

    signal_type {
      operator = "Equals"
      values   = ["Metric", "Log"]
    }

    target_resource {
      operator = "Contains"
      values   = ["resourseId1", "resourceId2"]
    }

    target_resource_group {
      operator = "DoesNotContain"
      values   = ["rg1", "rg2"]
    }

    target_resource_type {
      operator = "Equals"
      values   = ["Microsoft.Compute/VirtualMachines", "microsoft.batch/batchaccounts"]
    }
  }

  schedule {
    effective_from  = "2022-01-01T01:02:03"
    effective_until = "2022-02-02T01:02:03"
    time_zone       = "Pacific Standard Time"
    recurrence {
      daily {
        start_time = "17:00:00"
        end_time   = "09:00:00"
      }
      weekly {
        days_of_week = ["Sunday", "Saturday"]
      }
      weekly {
        start_time   = "17:00:00"
        end_time     = "18:00:00"
        days_of_week = ["Monday"]
      }
      monthly {
        start_time    = "09:00:00"
        end_time      = "12:00:00"
        days_of_month = [1, 15]
      }
    }
  }

  tags = {
    ENV  = "Test"
    ENV2 = "Test2"
  }
}
