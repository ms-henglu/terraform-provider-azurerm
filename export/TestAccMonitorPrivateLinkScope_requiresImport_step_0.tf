

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-220712042542968767"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-ampls-220712042542968767"
  resource_group_name = azurerm_resource_group.test.name
}
