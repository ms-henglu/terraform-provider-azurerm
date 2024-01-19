
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240119024539565299"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAutoAcct-240119024539565299"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_variable_datetime" "test" {
  name                    = "acctestAutoVar-240119024539565299"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  description             = "This variable is created by Terraform acceptance test."
  value                   = "2019-04-20T08:40:04.02Z"
  encrypted               = true
}
