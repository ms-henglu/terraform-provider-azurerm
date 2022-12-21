



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-221221203956548079"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-221221203956548079"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_connection_type" "test" {
  name                    = "acctest-221221203956548079"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  is_global               = false
  field {
    name = "my_def"
    type = "string"
  }
}
