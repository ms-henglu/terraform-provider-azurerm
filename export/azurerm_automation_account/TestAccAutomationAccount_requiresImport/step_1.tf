

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-221221203956544033"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-221221203956544033"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_account" "import" {
  name                = azurerm_automation_account.test.name
  location            = azurerm_automation_account.test.location
  resource_group_name = azurerm_automation_account.test.resource_group_name
  sku_name            = azurerm_automation_account.test.sku_name
}
