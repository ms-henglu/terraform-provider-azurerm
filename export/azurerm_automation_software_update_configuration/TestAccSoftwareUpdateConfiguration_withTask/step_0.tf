
resource "azurerm_automation_runbook" "test" {
  name                    = "Get-AzureVMTutorial"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name

  log_verbose  = "true"
  log_progress = "true"
  description  = "This is a test runbook for terraform acceptance test"
  runbook_type = "PowerShell"

  content = <<CONTENT
# Some test content
# for Terraform acceptance test
CONTENT
  tags = {
    ENV = "runbook_test"
  }
}


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240311031415485592"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240311031415485592"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240311031415485592"
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


resource "azurerm_automation_software_update_configuration" "test" {
  automation_account_id = azurerm_automation_account.test.id
  name                  = "acctest-suc-240311031415485592"

  linux {
    classification_included = "Security"
    excluded_packages       = ["apt"]
    included_packages       = ["vim"]
    reboot                  = "IfRequired"
  }

  duration            = "PT1H1M1S"
  virtual_machine_ids = []

  target {
    azure_query {
      scope     = [azurerm_resource_group.test.id]
      locations = [azurerm_resource_group.test.location]
    }

    non_azure_query {
      function_alias = "savedSearch1"
      workspace_id   = azurerm_log_analytics_workspace.test.id
    }
  }

  schedule {
    description         = "foo-schedule"
    start_time          = "2024-03-11T04:14:00Z"
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

  pre_task {
    source = azurerm_automation_runbook.test.name
    parameters = {
      COMPUTERNAME = "Foo"
    }
  }

  post_task {
    source = azurerm_automation_runbook.test.name
    parameters = {
      COMPUTERNAME = "Foo"
    }
  }

  depends_on = [azurerm_log_analytics_linked_service.test]
}
