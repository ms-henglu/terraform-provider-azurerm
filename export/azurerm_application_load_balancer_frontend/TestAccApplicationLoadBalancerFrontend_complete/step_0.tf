
provider "azurerm" {
  features {
  }
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-alb-240119025829285610"
  location = "West Europe"
}

resource "azurerm_application_load_balancer" "test" {
  name                = "acctestalb-240119025829285610"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_application_load_balancer_frontend" "test" {
  name                         = "acct-frnt-240119025829285610"
  application_load_balancer_id = azurerm_application_load_balancer.test.id
  tags = {
    "tag1" = "value1"
  }
}
