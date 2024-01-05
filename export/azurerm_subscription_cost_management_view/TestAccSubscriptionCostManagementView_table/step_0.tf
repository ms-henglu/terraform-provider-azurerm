
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

resource "azurerm_subscription_cost_management_view" "test" {
  name            = "testcostviewsz1x0"
  subscription_id = data.azurerm_subscription.test.id
  chart_type      = "Table"
  display_name    = "Test View sz1x0"

  accumulated = "false"
  report_type = "Usage"
  timeframe   = "MonthToDate"

  dataset {
    granularity = "Monthly"
    sorting {
      direction = "Ascending"
      name      = "BillingMonth"
    }
    grouping {
      name = "ResourceGroupName"
      type = "Dimension"
    }
    aggregation {
      name        = "totalCost"
      column_name = "Cost"
    }
    aggregation {
      name        = "totalCostUSD"
      column_name = "CostUSD"
    }
  }

  kpi {
    type = "Forecast"
  }
}
