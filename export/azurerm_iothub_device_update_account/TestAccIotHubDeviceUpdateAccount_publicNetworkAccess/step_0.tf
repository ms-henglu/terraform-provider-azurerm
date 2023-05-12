

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230512010824348206"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-1tt8d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  public_network_access_enabled = false
}
