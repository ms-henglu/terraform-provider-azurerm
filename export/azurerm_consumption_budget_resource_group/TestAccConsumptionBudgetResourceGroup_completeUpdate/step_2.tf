
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227175238065203"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestAG-230227175238065203"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestAG"
}

resource "azurerm_consumption_budget_resource_group" "test" {
  name              = "acctestconsumptionbudgetresourcegroup-230227175238065203"
  resource_group_id = azurerm_resource_group.test.id

  // Changed the amount from 1000 to 2000
  amount     = 2000
  time_grain = "Monthly"

  // Removed end_date
  time_period {
    start_date = "2023-02-01T00:00:00Z"
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
    enabled   = true
    threshold = 90.0
    operator  = "EqualTo"
    // We don't update the value of threshold_type because toggling between the two seems to be broken
    // See the comment on threshold_type in the schema for more details
    threshold_type = "Forecasted"

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
    enabled   = true
    threshold = 100.0
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
