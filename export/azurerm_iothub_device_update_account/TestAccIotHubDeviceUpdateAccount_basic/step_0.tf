

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230721011816983310"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-l9b18"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
