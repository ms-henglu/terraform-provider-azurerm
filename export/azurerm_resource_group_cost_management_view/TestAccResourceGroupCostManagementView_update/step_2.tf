
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230526084851764267"
  location = "West Europe"
}

resource "azurerm_resource_group_cost_management_view" "test" {
  name              = "testcostviewrs8zv"
  resource_group_id = azurerm_resource_group.test.id
  chart_type        = "Line"
  display_name      = "Test View 2 rs8zv"

  accumulated = "false"
  report_type = "Usage"
  timeframe   = "YearToDate"

  dataset {
    granularity = "Daily"
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
    name = "ResourceLocation"
  }
  pivot {
    type = "Dimension"
    name = "ResourceGroupName"
  }
  pivot {
    type = "Dimension"
    name = "ServiceName"
  }
}
