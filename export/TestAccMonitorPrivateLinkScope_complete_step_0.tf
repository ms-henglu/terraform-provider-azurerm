

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-211210024830117661"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-AMPLS-211210024830117661"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    ENV = "Test"
  }
}
