
provider "azurerm" {
  features {
  }
}

	
resource "azurerm_resource_group" "test" {
  name     = "acctestrg-alb-231020041859651429"
  location = "West Europe"
}


resource "azurerm_application_load_balancer" "test" {
  name                = "acctestalb-231020041859651429"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
