

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-220811053605664802"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-AMPLS-220811053605664802"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    ENV = "Test1"
  }
}
