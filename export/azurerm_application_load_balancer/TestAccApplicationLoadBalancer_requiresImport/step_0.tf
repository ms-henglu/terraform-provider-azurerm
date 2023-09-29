
provider "azurerm" {
  features {
  }
}

	
resource "azurerm_resource_group" "test" {
  name     = "acctestrg-alb-230929065718940840"
  location = "West Europe"
}


resource "azurerm_application_load_balancer" "test" {
  name                = "acctestalb-230929065718940840"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
