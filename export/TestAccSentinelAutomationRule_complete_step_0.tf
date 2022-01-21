

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-220121044943041868"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-220121044943041868"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "pergb2018"
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
  name                       = "ecf355e3-d007-4eb3-b678-19a510416aae"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-220121044943041868-update"
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
