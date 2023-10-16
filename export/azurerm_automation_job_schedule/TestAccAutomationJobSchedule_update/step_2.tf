

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231016033425292362"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-231016033425292362"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_runbook" "test" {
  name                    = "Output-HelloWorld"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is a test runbook for terraform acceptance test"
  runbook_type            = "PowerShell"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/c4935ffb69246a6058eb24f54640f53f69d3ac9f/101-automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
  }

  content = <<EOF
  param(
    [string]$Output = "World",

    [string]$Case = "Original",

    [int]$KeepCount = 10,

    [uri]$WebhookUri = "https://example.com/hook",

    [uri]$URL = "https://Example.com"
  )
  "Hello, " + $Output + "!"
EOF

}

resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-231016033425292362"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "OneTime"
}


resource "azurerm_automation_job_schedule" "test" {
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  schedule_name           = azurerm_automation_schedule.test.name
  runbook_name            = azurerm_automation_runbook.test.name
}
