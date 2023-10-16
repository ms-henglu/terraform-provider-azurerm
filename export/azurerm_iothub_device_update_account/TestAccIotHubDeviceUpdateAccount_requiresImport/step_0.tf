

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016034057241660"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-ild4y"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
