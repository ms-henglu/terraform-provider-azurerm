

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221028172252030689"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-fto4x"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  public_network_access_enabled = false
}
