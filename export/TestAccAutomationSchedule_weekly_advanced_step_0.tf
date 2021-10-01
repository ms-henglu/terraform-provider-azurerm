

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-211001053454334777"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-211001053454334777"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-211001053454334777"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "Week"
  interval                = "1"
  week_days               = ["Monday"]
}
