

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211210024743003064"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1210024743003064"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-10T09:47:43Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "e605f4a0-e65b-4ae5-91de-b9664f6c9039@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
