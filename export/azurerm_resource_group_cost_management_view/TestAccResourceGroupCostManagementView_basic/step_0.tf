
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230915023155500513"
  location = "West Europe"
}

resource "azurerm_resource_group_cost_management_view" "test" {
  name              = "testcostviewq4hln"
  resource_group_id = azurerm_resource_group.test.id
  chart_type        = "StackedColumn"
  display_name      = "Test View q4hln"

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
  pivot {
    type = "Dimension"
    name = "ServiceName"
  }
  pivot {
    type = "Dimension"
    name = "ResourceLocation"
  }
  pivot {
    type = "Dimension"
    name = "ResourceGroupName"
  }
}
