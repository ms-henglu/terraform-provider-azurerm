

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240311031415471293"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-240311031415471293"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-240311031415471293"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "Week"
  interval                = 1
  timezone                = "Europe/Amsterdam"
  start_time              = "2026-04-15T18:01:15+02:00"
  description             = "foo"
  week_days               = ["Monday"]
}
