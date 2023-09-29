

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230929064424197833"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-230929064424197833"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_credential" "test" {
  name                    = "acctest-230929064424197833"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  username                = "test_user"
  password                = "test_pwd"
}


resource "azurerm_automation_credential" "import" {
  name                    = azurerm_automation_credential.test.name
  resource_group_name     = azurerm_automation_credential.test.resource_group_name
  automation_account_name = azurerm_automation_credential.test.automation_account_name
  username                = azurerm_automation_credential.test.username
  password                = azurerm_automation_credential.test.password
}
