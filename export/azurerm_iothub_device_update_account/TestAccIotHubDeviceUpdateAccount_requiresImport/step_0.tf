

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231013043619729821"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-t3jy2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
