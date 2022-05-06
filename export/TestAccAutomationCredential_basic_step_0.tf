
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-220506005431517292"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-220506005431517292"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_credential" "test" {
  name                    = "acctest-220506005431517292"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  username                = "test_user"
  password                = "test_pwd"
}
