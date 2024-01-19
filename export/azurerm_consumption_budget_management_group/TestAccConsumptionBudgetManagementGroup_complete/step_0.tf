
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_management_group" "tenant_root" {
  name = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024721034848"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestAG-240119024721034848"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestAG"
}

resource "azurerm_consumption_budget_management_group" "test" {
  name                = "acctestconsumptionbudgetManagementGroup-240119024721034848"
  management_group_id = data.azurerm_management_group.tenant_root.id

  amount     = 1000
  time_grain = "Monthly"

  time_period {
    start_date = "2024-01-01T00:00:00Z"
    end_date   = "2025-02-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceGroupName"
      values = [
        azurerm_resource_group.test.name,
      ]
    }

    dimension {
      name = "ResourceId"
      values = [
        azurerm_monitor_action_group.test.id,
      ]
    }

    tag {
      name = "foo"
      values = [
        "bar",
        "baz",
      ]
    }
  }

  notification {
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }

  notification {
    enabled        = false
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
}
