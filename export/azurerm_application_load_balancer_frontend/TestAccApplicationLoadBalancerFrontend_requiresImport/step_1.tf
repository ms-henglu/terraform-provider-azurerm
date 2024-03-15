
	
provider "azurerm" {
  features {
  }
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-alb-240315124055446663"
  location = "West Europe"
}

resource "azurerm_application_load_balancer" "test" {
  name                = "acctestalb-240315124055446663"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_application_load_balancer_frontend" "test" {
  name                         = "acct-frnt-240315124055446663"
  application_load_balancer_id = azurerm_application_load_balancer.test.id
}


resource "azurerm_application_load_balancer_frontend" "import" {
  name                         = azurerm_application_load_balancer_frontend.test.name
  application_load_balancer_id = azurerm_application_load_balancer_frontend.test.application_load_balancer_id
}
