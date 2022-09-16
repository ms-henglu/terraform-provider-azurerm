

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databoxedge-220916011317066573"
  location = "eastus"
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acctest-dd-mupuy"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"

  tags = {
    ENV = "Test"
  }
}
