

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-230804030334128590"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-ampls-230804030334128590"
  resource_group_name = azurerm_resource_group.test.name
}
