
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024721033930"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestAG-240119024721033930"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestAG"
}

resource "azurerm_consumption_budget_subscription" "test" {
  name            = "acctestconsumptionbudgetsubscription-240119024721033930"
  subscription_id = data.azurerm_subscription.current.id

  // Changed the amount from 1000 to 2000
  amount     = 2000
  time_grain = "Monthly"

  // Removed end_date
  time_period {
    start_date = "2024-01-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceGroupName"
      values = [
        azurerm_resource_group.test.name,
      ]
    }

    tag {
      name = "foo"
      values = [
        "bar",
        "baz",
      ]
    }

    // Added tag: zip
    tag {
      name = "zip"
      values = [
        "zap",
        "zop",
      ]
    }

    // Removed not block 
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = [
      // Added baz@example.com
      "baz@example.com",
      "foo@example.com",
      "bar@example.com",
    ]

    contact_groups = [
      azurerm_monitor_action_group.test.id,
    ]
    // Removed contact_roles
  }

  notification {
    // Set enabled to true
    enabled        = true
    threshold      = 100.0
    threshold_type = "Forecasted"
    // Changed from EqualTo to GreaterThanOrEqualTo 
    operator = "GreaterThanOrEqualTo"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]

    // Added contact_groups
    contact_groups = [
      azurerm_monitor_action_group.test.id,
    ]
  }
}
