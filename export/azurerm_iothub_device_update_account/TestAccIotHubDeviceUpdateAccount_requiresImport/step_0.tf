

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119025151958833"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-d4qsi"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
