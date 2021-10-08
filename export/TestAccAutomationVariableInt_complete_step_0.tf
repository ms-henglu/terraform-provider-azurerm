
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-211008044059783592"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAutoAcct-211008044059783592"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_variable_int" "test" {
  name                    = "acctestAutoVar-211008044059783592"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  description             = "This variable is created by Terraform acceptance test."
  value                   = 12345
}
