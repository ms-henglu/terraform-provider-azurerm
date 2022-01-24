


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220124122311343107"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0124122311343107"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-24T19:23:11Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "9beb101a-8322-40de-b979-c51dfd54c3f7@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_logz_monitor" "import" {
  name                = azurerm_logz_monitor.test.name
  resource_group_name = azurerm_logz_monitor.test.resource_group_name
  location            = azurerm_logz_monitor.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-24T19:23:11Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "9beb101a-8322-40de-b979-c51dfd54c3f7@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
