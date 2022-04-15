

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-220415030825351489"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-AMPLS-220415030825351489"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    ENV = "Test2"
  }
}
