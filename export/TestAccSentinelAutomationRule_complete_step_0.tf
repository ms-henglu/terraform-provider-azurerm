

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-220627131758211411"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-220627131758211411"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "sentinel" {
  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}


data "azurerm_client_config" "current" {}

resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "0f1cec0e-3b91-47df-aeaa-f9c1ede78cde"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-220627131758211411-update"
  order                      = 2
  enabled                    = false
  expiration                 = "2022-11-20T15:44:52Z"
  condition {
    property = "IncidentTitle"
    operator = "Contains"
    values   = ["a", "b"]
  }

  condition {
    property = "IncidentTitle"
    operator = "Contains"
    values   = ["c", "d"]
  }

  action_incident {
    order                  = 1
    status                 = "Closed"
    classification         = "BenignPositive_SuspiciousButExpected"
    classification_comment = "whatever reason"
  }

  action_incident {
    order  = 3
    labels = ["foo", "bar"]
  }

  action_incident {
    order    = 2
    severity = "High"
  }

  action_incident {
    order    = 4
    owner_id = data.azurerm_client_config.current.object_id
  }
}
