

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119025151958351"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-ef6i6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
