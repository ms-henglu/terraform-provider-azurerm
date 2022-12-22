

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-221222034249695068"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-221222034249695068"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-221222034249695068"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "Month"
  interval                = "1"
  month_days              = [2]
}
