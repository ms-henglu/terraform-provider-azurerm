

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220527034347566881"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0527034347566881"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-05-27T10:43:47Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "f12cc31e-c649-41cd-8991-730484aebd65@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
