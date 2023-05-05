

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230505050559440998"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-v9z7q"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
