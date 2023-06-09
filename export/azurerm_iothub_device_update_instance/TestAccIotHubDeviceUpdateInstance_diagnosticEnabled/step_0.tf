

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230609091428974497"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230609091428974497"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-juilc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_iothub_device_update_instance" "test" {
  name                     = "acc-dui-juilc"
  device_update_account_id = azurerm_iothub_device_update_account.test.id
  iothub_id                = azurerm_iothub.test.id

  diagnostic_enabled = true
}
