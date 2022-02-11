

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-220211043236320692"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-220211043236320692"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-220211043236320692"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "OneTime"
  start_time              = "2022-02-11T19:32:00+08:00"
  timezone                = "Australia/Perth"
  description             = "This is an automation schedule"
}
