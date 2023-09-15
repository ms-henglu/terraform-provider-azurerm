

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230915022932635513"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-230915022932635513"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-230915022932635513"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "Month"
  interval                = "1"

  monthly_occurrence {
    day        = "Monday"
    occurrence = "2"
  }
}
