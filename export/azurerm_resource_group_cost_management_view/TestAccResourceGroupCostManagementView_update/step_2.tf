
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cm-231016033652971461"
  location = "West Europe"
}

resource "azurerm_resource_group_cost_management_view" "test" {
  name              = "testcostview1jen1"
  resource_group_id = azurerm_resource_group.test.id
  chart_type        = "Line"
  display_name      = "Test View 2 1jen1"

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
