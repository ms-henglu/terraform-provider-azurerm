

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230324051944621002"
  location = "West Europe"
}


resource "azurerm_data_protection_resource_guard" "test" {
  name                = "acctest-dprg-230324051944621002"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
