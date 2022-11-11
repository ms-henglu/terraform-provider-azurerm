

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221111013659245613"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-221111013659245613"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-n3txv"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_iothub_device_update_instance" "test" {
  name                     = "acc-dui-n3txv"
  device_update_account_id = azurerm_iothub_device_update_account.test.id
  iothub_id                = azurerm_iothub.test.id

  diagnostic_enabled = false
}
