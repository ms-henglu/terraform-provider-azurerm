


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240315122349370528"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240315122349370528"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240315122349370528"
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
  name                  = "acctest-suc-240315122349370528"

  linux {
    classifications_included = ["Security"]
  }

  target {
    azure_query {
      scope     = [azurerm_resource_group.test.id]
      locations = [azurerm_resource_group.test.location]
    }
  }

  schedule {
    frequency = "OneTime"
  }

  depends_on = [azurerm_log_analytics_linked_service.test]
}
