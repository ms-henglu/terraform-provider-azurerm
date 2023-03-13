



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230313020743494753"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-230313020743494753"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_credential" "test" {
  name                    = "acctest-230313020743494753"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  username                = "test_user"
  password                = "test_pwd"
}


resource "azurerm_automation_hybrid_runbook_worker_group" "test" {
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  name                    = "acctest-230313020743494753"
  credential_name         = azurerm_automation_credential.test.name
}
