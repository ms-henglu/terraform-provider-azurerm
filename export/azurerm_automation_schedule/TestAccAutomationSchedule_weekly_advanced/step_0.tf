

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240119024539565714"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-240119024539565714"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-240119024539565714"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "Week"
  interval                = "1"
  week_days               = ["Monday"]
}
