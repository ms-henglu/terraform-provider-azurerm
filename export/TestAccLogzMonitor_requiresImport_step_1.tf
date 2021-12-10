


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211210035005883444"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1210035005883444"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-10T10:50:05Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "c9e6084c-2652-49d2-82fd-717886b6b2c0@example.com"
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
    effective_date = "2021-12-10T10:50:05Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "c9e6084c-2652-49d2-82fd-717886b6b2c0@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
