



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-221104005126722933"
  location = "West US"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-221104005126722933"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-221104005126722933"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_linked_service" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  read_access_id      = azurerm_automation_account.test.id
}


resource "azurerm_automation_software_update_configuration" "test" {
  automation_account_id = azurerm_automation_account.test.id
  name                  = "acctest-suc-221104005126722933"
  operating_system      = "Windows"

  windows {
    classifications_included = ["Critical", "Security"]
    reboot                   = "IfRequired"
  }

  duration            = "PT1H1M1S"
  virtual_machine_ids = []

  target {
    azure_query {
      scope     = [azurerm_resource_group.test.id]
      locations = [azurerm_resource_group.test.location]
      tags {
        tag    = "foo"
        values = ["barbar2"]
      }
      tag_filter = "Any"
    }

    non_azure_query {
      function_alias = "savedSearch1"
      workspace_id   = azurerm_log_analytics_workspace.test.id
    }
  }

  schedule {
    description         = "foo-schedule"
    start_time          = "2022-11-04T10:51:26Z"
    expiry_time         = "2022-11-06T02:51:26Z"
    is_enabled          = true
    interval            = 1
    frequency           = "Hour"
    time_zone           = "Etc/UTC"
    advanced_week_days  = ["Monday", "Tuesday"]
    advanced_month_days = [1, 10, 15]
    monthly_occurrence {
      occurrence = 1
      day        = "Tuesday"
    }
  }

  depends_on = [azurerm_log_analytics_linked_service.test]
}
