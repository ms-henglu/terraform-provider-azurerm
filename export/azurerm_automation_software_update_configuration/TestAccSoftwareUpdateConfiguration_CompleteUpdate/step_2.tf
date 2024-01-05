


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240105060313955352"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240105060313955352"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240105060313955352"
  location            = "west europe"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_linked_service" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  read_access_id      = azurerm_automation_account.test.id
}


data "azurerm_client_config" "current" {}

resource "azurerm_automation_software_update_configuration" "test" {
  automation_account_id = azurerm_automation_account.test.id
  name                  = "acctest-suc-240105060313955352"

  linux {
    classification_included = "Security"
    excluded_packages       = ["apt"]
    included_packages       = ["vim"]
    reboot                  = "Always"
  }

  duration            = "PT2H2M2S"
  virtual_machine_ids = []

  target {
    azure_query {
      scope     = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
      locations = [azurerm_resource_group.test.location]
      tags {
        tag    = "foo"
        values = ["barbar2"]
      }
      tag_filter = "Any"
    }

    non_azure_query {
      function_alias = "savedSearch2"
      workspace_id   = azurerm_log_analytics_workspace.test.id
    }
  }

  schedule {
    description        = "foobar-schedule"
    start_time         = "2024-01-05T07:03:00Z"
    expiry_time        = "2024-01-05T08:03:00Z"
    is_enabled         = true
    interval           = 2
    frequency          = "Hour"
    time_zone          = "Etc/UTC"
    advanced_week_days = ["Monday", "Tuesday"]
  }

  depends_on = [azurerm_log_analytics_linked_service.test]
}
