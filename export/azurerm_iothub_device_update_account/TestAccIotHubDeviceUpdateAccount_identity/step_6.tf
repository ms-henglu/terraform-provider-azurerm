

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231020041232720016"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-ojtzc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
