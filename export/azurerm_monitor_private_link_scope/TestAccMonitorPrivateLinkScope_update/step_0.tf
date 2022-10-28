

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-221028172502867774"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-AMPLS-221028172502867774"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    ENV = "Test1"
  }
}
