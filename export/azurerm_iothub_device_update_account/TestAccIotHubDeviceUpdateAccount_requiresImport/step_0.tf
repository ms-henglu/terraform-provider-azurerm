

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230127045538366332"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-zq02l"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
