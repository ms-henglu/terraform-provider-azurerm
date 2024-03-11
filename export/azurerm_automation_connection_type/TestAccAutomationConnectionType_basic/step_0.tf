



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240311031415468513"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240311031415468513"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_connection_type" "test" {
  name                    = "acctest-240311031415468513"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  is_global               = false
  field {
    name = "my_def"
    type = "string"
  }
}
