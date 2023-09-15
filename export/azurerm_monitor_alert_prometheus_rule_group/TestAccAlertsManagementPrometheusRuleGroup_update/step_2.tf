
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230915023817056448"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230915023817056448"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"
}

resource "azurerm_monitor_workspace" "test" {
  name                = "acctest-amw-230915023817056448"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}



resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230915023817056448"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230915023817056448"

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

resource "azurerm_kubernetes_cluster" "test2" {
  name                = "acctestaks2230915023817056448"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks2230915023817056448"

  default_node_pool {
    name                   = "default"
    node_count             = 2
    vm_size                = "Standard_DS2_v2"
    enable_host_encryption = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_monitor_action_group" "test2" {
  name                = "acctestActionGroup2-230915023817056448"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag2"
}

resource "azurerm_monitor_alert_prometheus_rule_group" "test" {
  name                = "acctest-amprg-230915023817056448"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  cluster_name        = azurerm_kubernetes_cluster.test2.name
  description         = "This is the description of the following rule group2"
  rule_group_enabled  = true
  interval            = "PT10M"
  scopes              = [azurerm_monitor_workspace.test.id]

  rule {
    enabled    = true
    expression = <<EOF
histogram_quantile(0.99, sum(rate(jobs_duration_seconds_bucket{service="billing-processing"}[5m])) by (job_type))
EOF
    record     = "job_type:billing_jobs_duration_seconds:99p6m"
    labels = {
      team2 = "prod2"
    }
  }

  rule {
    alert      = "Billing_Processing_Very_Slow2"
    enabled    = false
    expression = <<EOF
histogram_quantile(0.99, sum(rate(jobs_duration_seconds_bucket{service="billing-processing"}[5m])) by (job_type))
EOF
    for        = "PT4M"
    severity   = 1
    action {
      action_group_id = azurerm_monitor_action_group.test2.id
    }
    action {
      action_group_id = azurerm_monitor_action_group.test.id
    }
    alert_resolution {
      auto_resolved   = false
      time_to_resolve = "PT9M"
    }
    annotations = {
      annotationName2 = "annotationValue2"
    }
    labels = {
      team2 = "prod2"
    }
  }
  tags = {
    key2 = "value2"
  }
}
