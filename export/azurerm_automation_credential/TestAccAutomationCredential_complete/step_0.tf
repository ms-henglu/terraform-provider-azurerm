
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231016033425292746"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-231016033425292746"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_credential" "test" {
  name                    = "acctest-231016033425292746"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  username                = "test_user"
  password                = "test_pwd"
  description             = "This is a test credential for terraform acceptance test"
}
