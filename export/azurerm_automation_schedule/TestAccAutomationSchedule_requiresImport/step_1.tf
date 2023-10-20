


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231020040612495874"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-231020040612495874"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_schedule" "test" {
  name                    = "acctestAS-231020040612495874"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  frequency               = "OneTime"
}


resource "azurerm_automation_schedule" "import" {
  name                    = azurerm_automation_schedule.test.name
  resource_group_name     = azurerm_automation_schedule.test.resource_group_name
  automation_account_name = azurerm_automation_schedule.test.automation_account_name
  frequency               = azurerm_automation_schedule.test.frequency
}
