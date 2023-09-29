
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230929064424206623"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-230929064424206623"
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

  publish_content_link {
    uri = ""
  }
}
