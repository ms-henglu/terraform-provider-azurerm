

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-220726014520511666"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-220726014520511666"
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
  expiry_time             = "2022-07-26T02:45:20Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.test.name
  uri                     = "https://12345678-9012-3456-7890-123456789012.webhook.we.azure-automation.net/webhooks?token=abcdefghijklmnoprstuwxyz1234567890abcdefg313377"
}
