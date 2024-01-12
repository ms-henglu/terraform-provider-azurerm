


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112034527562372"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-nk2wm"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_iothub_device_update_account" "import" {
  name                = azurerm_iothub_device_update_account.test.name
  resource_group_name = azurerm_iothub_device_update_account.test.resource_group_name
  location            = azurerm_iothub_device_update_account.test.location
}
