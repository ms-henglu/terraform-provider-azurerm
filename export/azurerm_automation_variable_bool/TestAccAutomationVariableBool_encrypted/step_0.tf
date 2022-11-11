
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-221111013121741508"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAutoAcct-221111013121741508"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_variable_bool" "test" {
  name                    = "acctestAutoVar-221111013121741508"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  value                   = false
  encrypted               = true
}
