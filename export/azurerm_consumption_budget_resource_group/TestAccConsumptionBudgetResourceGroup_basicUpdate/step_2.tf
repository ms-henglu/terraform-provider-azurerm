
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033617946845"
  location = "West Europe"
}

resource "azurerm_consumption_budget_resource_group" "test" {
  name              = "acctestconsumptionbudgetresourcegroup-231016033617946845"
  resource_group_id = azurerm_resource_group.test.id

  // Changed the amount from 1000 to 2000
  amount     = 3000
  time_grain = "Monthly"

  // Add end_date
  time_period {
    start_date = "2023-10-01T00:00:00Z"
    end_date   = "2024-11-01T00:00:00Z"
  }

  // Remove filter

  // Changed threshold and operator
  notification {
    enabled        = true
    threshold      = 95.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
}
