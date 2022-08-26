

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-220826003031545941"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-AMPLS-220826003031545941"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    ENV = "Test"
  }
}
