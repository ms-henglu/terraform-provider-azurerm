

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databoxedge-230203063146180407"
  location = "eastus"
}


resource "azurerm_databox_edge_device" "test" {
  name                = "acctest-dd-k2e8s"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"

  tags = {
    ENV = "Test"
  }
}
