

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-pls-240119025423993780"
  location = "West Europe"
}


resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-ampls-240119025423993780"
  resource_group_name = azurerm_resource_group.test.name
}
