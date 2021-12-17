
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "test" {
  name            = "acctestconsumptionbudgetsubscription-211217035039355808"
  subscription_id = data.azurerm_subscription.current.subscription_id

  // Changed the amount from 1000 to 2000
  amount     = 3000
  time_grain = "Monthly"

  // Add end_date
  time_period {
    start_date = "2021-12-01T00:00:00Z"
    end_date   = "2023-01-01T00:00:00Z"
  }

  // Remove filter

  // Changed threshold and operator
  notification {
    enabled        = true
    threshold      = 95.0
    threshold_type = "Forecasted"
    operator       = "GreaterThan"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
}
