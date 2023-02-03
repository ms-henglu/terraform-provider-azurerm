

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230203063224030701"
  location = "West Europe"
}


resource "azurerm_data_protection_resource_guard" "test" {
  name                = "acctest-dprg-230203063224030701"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
