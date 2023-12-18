

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231218071306460861"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-231218071306460861"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-231218071306460861"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "Week"
  interval                = 1
  timezone                = "Europe/Amsterdam"
  start_time              = "2026-04-15T18:01:15+02:00"
  description             = "bar"
  week_days               = ["Monday"]
}
