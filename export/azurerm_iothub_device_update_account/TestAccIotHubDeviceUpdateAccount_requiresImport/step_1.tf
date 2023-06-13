


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230613072019975034"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-a8t7y"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_iothub_device_update_account" "import" {
  name                = azurerm_iothub_device_update_account.test.name
  resource_group_name = azurerm_iothub_device_update_account.test.resource_group_name
  location            = azurerm_iothub_device_update_account.test.location
}
