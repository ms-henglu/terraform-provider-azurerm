
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112224854947013"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240112224854947013"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_monitor_workspace" "test" {
  name                = "acctest-amw-240112224854947013"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}



resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240112224854947013"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240112224854947013"

  default_node_pool {
    name                   = "default"
    node_count             = 1
    vm_size                = "Standard_DS2_v2"
    enable_host_encryption = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_monitor_alert_prometheus_rule_group" "test" {
  name                = "acctest-amprg-240112224854947013"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  cluster_name        = azurerm_kubernetes_cluster.test.name
  description         = "This is the description of the following rule group"
  rule_group_enabled  = false
  interval            = "PT10M"
  scopes              = [azurerm_monitor_workspace.test.id]
  rule {
    enabled    = false
    expression = <<EOF
histogram_quantile(0.99, sum(rate(jobs_duration_seconds_bucket{service="billing-processing"}[5m])) by (job_type))
EOF
    record     = "job_type:billing_jobs_duration_seconds:99p5m"
    labels = {
      team = "prod"
    }
  }
  rule {
    alert      = "Billing_Processing_Very_Slow"
    enabled    = true
    expression = <<EOF
histogram_quantile(0.99, sum(rate(jobs_duration_seconds_bucket{service="billing-processing"}[5m])) by (job_type))
EOF
    for        = "PT5M"
    severity   = 2
    action {
      action_group_id = azurerm_monitor_action_group.test.id
    }
    alert_resolution {
      auto_resolved   = true
      time_to_resolve = "PT10M"
    }
    annotations = {
      annotationName = "annotationValue"
    }
    labels = {
      team = "prod"
    }
  }
  tags = {
    key = "value"
  }
}
