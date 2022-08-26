

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databoxedge-220826002551466344"
  location = "eastus"
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acctest-dd-8nqqr"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"
}
