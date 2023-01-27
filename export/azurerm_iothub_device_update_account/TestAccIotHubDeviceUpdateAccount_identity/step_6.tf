

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230127045538365706"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-d0ypp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
