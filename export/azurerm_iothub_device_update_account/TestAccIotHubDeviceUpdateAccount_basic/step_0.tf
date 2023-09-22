

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230922054257610782"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-hunxj"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
