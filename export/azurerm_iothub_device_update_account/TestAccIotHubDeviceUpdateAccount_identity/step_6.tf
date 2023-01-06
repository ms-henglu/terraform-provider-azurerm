

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230106034558959623"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-mre4n"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
