

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220124122311344396"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0124122311344396"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-24T19:23:11Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "11b57f81-19e7-4097-987f-59aa403d3efd@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
