
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-230804025712971334"
  location = "West Europe"
}

resource "azurerm_resource_group_cost_management_view" "test" {
  name              = "testcostviewl7hrr"
  resource_group_id = azurerm_resource_group.test.id
  chart_type        = "Line"
  display_name      = "Test View 2 l7hrr"

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
