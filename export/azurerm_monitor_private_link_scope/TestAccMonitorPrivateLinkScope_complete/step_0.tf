

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-230707010700910106"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-AMPLS-230707010700910106"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    ENV = "Test"
  }
}
