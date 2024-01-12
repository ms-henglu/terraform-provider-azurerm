
provider "azurerm" {
  features {
  }
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-alb-240112225254895440"
  location = "West Europe"
}

resource "azurerm_application_load_balancer" "test" {
  name                = "acctestalb-240112225254895440"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_application_load_balancer_frontend" "test" {
  name                         = "acct-frnt-240112225254895440"
  application_load_balancer_id = azurerm_application_load_balancer.test.id
}
