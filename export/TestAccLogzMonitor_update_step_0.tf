

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211210035005884237"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1210035005884237"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-10T10:50:05Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "492a1ed0-2036-4f0f-9526-0c03415fdc2d@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
