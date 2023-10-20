
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231020041503950079"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-231020041503950079"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_monitor_workspace" "test" {
  name                = "acctest-amw-231020041503950079"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}



resource "azurerm_monitor_alert_prometheus_rule_group" "test" {
  name                = "acctest-amprg-231020041503950079"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  scopes              = [azurerm_monitor_workspace.test.id]
  rule {
    expression = <<EOF
histogram_quantile(0.99, sum(rate(jobs_duration_seconds_bucket{service="billing-processing"}[5m])) by (job_type))
EOF
    record     = "job_type:billing_jobs_duration_seconds:99p5m"
    labels = {
      team = "prod"
    }
  }
}
