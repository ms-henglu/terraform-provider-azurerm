
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230929064646075593"
  location = "West Europe"
}

resource "azurerm_resource_group_cost_management_view" "test" {
  name              = "testcostviewe6cdb"
  resource_group_id = azurerm_resource_group.test.id
  chart_type        = "Table"
  display_name      = "Test View e6cdb"

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
