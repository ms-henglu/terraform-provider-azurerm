

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-211001020515213051"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-211001020515213051"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-211001020515213051"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "OneTime"
  start_time              = "2021-10-01T17:05:00+08:00"
  timezone                = "Australia/Perth"
  description             = "This is an automation schedule"
}
