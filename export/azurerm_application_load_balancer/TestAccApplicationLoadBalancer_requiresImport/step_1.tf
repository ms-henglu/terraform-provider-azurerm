
	
provider "azurerm" {
  features {
  }
}

	
resource "azurerm_resource_group" "test" {
  name     = "acctestrg-alb-240119022847940081"
  location = "West Europe"
}


resource "azurerm_application_load_balancer" "test" {
  name                = "acctestalb-240119022847940081"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_application_load_balancer" "import" {
  name                = azurerm_application_load_balancer.test.name
  location            = azurerm_application_load_balancer.test.location
  resource_group_name = azurerm_application_load_balancer.test.resource_group_name
}
