


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databoxedge-210825044643937537"
  location = "eastus"
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acctest-dd-3uf8d"
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
