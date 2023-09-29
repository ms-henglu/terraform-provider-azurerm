

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230929064424205699"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-230929064424205699"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-230929064424205699"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "OneTime"
  start_time              = "2023-09-29T21:44:00+08:00"
  timezone                = "Australia/Perth"
  description             = "This is an automation schedule"
}
