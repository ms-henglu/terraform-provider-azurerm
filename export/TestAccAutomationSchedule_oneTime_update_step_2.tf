

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-220715004144481103"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-220715004144481103"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-220715004144481103"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "OneTime"
  start_time              = "2022-07-15T15:41:00+08:00"
  timezone                = "Australia/Perth"
  description             = "This is an automation schedule"
}
