

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-211029020132477626"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-211029020132477626"
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

data "azuread_service_principal" "securityinsights" {
  display_name = "Azure Security Insights"
}

resource "azurerm_role_assignment" "sentinel" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Azure Sentinel Automation Contributor"
  principal_id         = data.azuread_service_principal.securityinsights.object_id
}

resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "1c87712c-d236-4ba7-9d93-cf95f18f8ded"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-211029020132477626-update"
  order                      = 2
  enabled                    = false
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

  depends_on = [azurerm_role_assignment.sentinel]
}
