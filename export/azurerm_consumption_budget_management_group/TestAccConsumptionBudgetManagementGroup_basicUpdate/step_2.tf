
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_management_group" "tenant_root" {
  name = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_consumption_budget_management_group" "test" {
  name                = "acctestconsumptionbudgetManagementGroup-240311031645001549"
  management_group_id = data.azurerm_management_group.tenant_root.id

  // Changed the amount from 1000 to 3000
  amount     = 3000
  time_grain = "Monthly"

  // Add end_date
  time_period {
    start_date = "2024-03-01T00:00:00Z"
    end_date   = "2025-04-01T00:00:00Z"
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
