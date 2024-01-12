


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240112033911114644"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240112033911114644"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

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
}


resource "azurerm_automation_webhook" "test" {
  name                    = "TestRunbook_webhook"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  expiry_time             = "2024-01-12T04:39:11Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.test.name
}


resource "azurerm_automation_webhook" "import" {
  name                    = azurerm_automation_webhook.test.name
  resource_group_name     = azurerm_automation_webhook.test.resource_group_name
  automation_account_name = azurerm_automation_webhook.test.automation_account_name
  expiry_time             = azurerm_automation_webhook.test.expiry_time
  enabled                 = azurerm_automation_webhook.test.enabled
  runbook_name            = azurerm_automation_webhook.test.runbook_name
}
