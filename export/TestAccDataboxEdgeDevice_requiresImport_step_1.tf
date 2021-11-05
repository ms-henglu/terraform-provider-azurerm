


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databoxedge-211105035734280670"
  location = "eastus"
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acctest-dd-4t1tl"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"
}


resource "azurerm_databox_edge_device" "import" {
  name                = azurerm_databox_edge_device.test.name
  resource_group_name = azurerm_databox_edge_device.test.resource_group_name
  location            = azurerm_databox_edge_device.test.location

  sku_name = "EdgeP_Base-Standard"
}
