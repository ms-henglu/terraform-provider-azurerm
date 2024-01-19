

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119025151951923"
  location = "West Europe"
}


resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-dpr37"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "AccTest"
  }
}
