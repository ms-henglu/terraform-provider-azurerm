
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-220916011632507239"
  location = "West Europe"
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-220916011632507239"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Purpose = "AcceptanceTests"
  }
}
