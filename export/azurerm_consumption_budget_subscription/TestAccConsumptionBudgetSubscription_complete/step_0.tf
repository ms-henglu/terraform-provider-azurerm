
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023122453168"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestAG-230915023122453168"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestAG"
}

resource "azurerm_consumption_budget_subscription" "test" {
  name            = "acctestconsumptionbudgetsubscription-230915023122453168"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 1000
  time_grain = "Monthly"

  time_period {
    start_date = "2023-09-01T00:00:00Z"
    end_date   = "2024-10-01T00:00:00Z"
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

    contact_groups = [
      azurerm_monitor_action_group.test.id,
    ]

    contact_roles = [
      "Owner",
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
