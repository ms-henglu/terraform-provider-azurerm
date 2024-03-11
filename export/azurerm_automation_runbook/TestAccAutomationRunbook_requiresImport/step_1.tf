

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240311031415477465"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240311031415477465"
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
  tags = {
    ENV = "runbook_test"
  }
}


resource "azurerm_automation_runbook" "import" {
  name                    = azurerm_automation_runbook.test.name
  location                = azurerm_automation_runbook.test.location
  resource_group_name     = azurerm_automation_runbook.test.resource_group_name
  automation_account_name = azurerm_automation_runbook.test.automation_account_name

  log_verbose  = "true"
  log_progress = "true"
  description  = "This is a test runbook for terraform acceptance test"
  runbook_type = "PowerShell"

  content = <<CONTENT
# Some test content
# for Terraform acceptance test
CONTENT
}
