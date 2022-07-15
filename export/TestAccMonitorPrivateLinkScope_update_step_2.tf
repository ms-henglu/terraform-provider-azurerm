

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-220715004703384756"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-AMPLS-220715004703384756"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    ENV = "Test2"
  }
}
