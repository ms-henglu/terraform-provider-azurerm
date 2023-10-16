

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231016033425302664"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-231016033425302664"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-231016033425302664"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "OneTime"
  start_time              = "2023-10-16T18:34:00+08:00"
  timezone                = "Australia/Perth"
  description             = "This is an automation schedule"
}
