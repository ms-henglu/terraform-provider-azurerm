
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240119024539572051"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAutoAcct-240119024539572051"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_variable_object" "test" {
  name                    = "acctestAutoVar-240119024539572051"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  value                   = jsonencode({ property = "Hello, Terraform Basic Test." })
}
