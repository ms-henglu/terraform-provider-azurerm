
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-240119024757254274"
  location = "West Europe"
}

resource "azurerm_resource_group_cost_management_view" "test" {
  name              = "testcostview00x2u"
  resource_group_id = azurerm_resource_group.test.id
  chart_type        = "Table"
  display_name      = "Test View 00x2u"

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
