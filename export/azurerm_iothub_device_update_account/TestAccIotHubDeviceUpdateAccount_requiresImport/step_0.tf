

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221202035818111859"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-i0bf2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
