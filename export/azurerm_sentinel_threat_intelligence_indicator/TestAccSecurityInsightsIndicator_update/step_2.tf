
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230922061858830289"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230922061858830289"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
}


resource "azurerm_sentinel_threat_intelligence_indicator" "test" {
  workspace_id    = azurerm_log_analytics_workspace.test.id
  pattern_type    = "domain-name"
  pattern         = "http://example.com"
  confidence      = 5
  created_by      = "testcraeted@microsoft.com"
  description     = "updated indicator"
  display_name    = "updated"
  language        = "en"
  pattern_version = 1
  revoked         = true
  tags            = ["updated-tags"]
  kill_chain_phase {
    name = "testtest"
  }
  external_reference {
    description = "test-external"
    source_name = "test-sourcename"
  }
  granular_marking {
    language = "en"
  }
  source            = "updated Sentinel"
  validate_from_utc = "2022-12-15T16:00:00Z"

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.test]
}
