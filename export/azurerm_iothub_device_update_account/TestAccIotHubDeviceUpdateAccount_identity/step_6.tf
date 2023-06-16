

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230616074901635594"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-eq3gs"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
