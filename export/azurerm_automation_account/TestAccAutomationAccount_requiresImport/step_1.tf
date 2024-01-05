

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240105063334932221"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                         = "acctest-240105063334932221"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku_name                     = "Basic"
  local_authentication_enabled = false
}


resource "azurerm_automation_account" "import" {
  name                = azurerm_automation_account.test.name
  location            = azurerm_automation_account.test.location
  resource_group_name = azurerm_automation_account.test.resource_group_name
  sku_name            = azurerm_automation_account.test.sku_name
}
