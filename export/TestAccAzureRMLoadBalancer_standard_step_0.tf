
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-220916011632501464"
  location = "West Europe"
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-220916011632501464"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  sku_tier            = "Global"

  tags = {
    Environment = "production"
    Purpose     = "AcceptanceTests"
  }
}
