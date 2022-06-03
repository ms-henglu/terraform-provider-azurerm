


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220603005022664541"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0603005022664541"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-06-03T07:50:22Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "3e24ef81-c50b-4cc3-aad3-d51f859c6a81@example.com"
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
    billing_cycle  = "MONTHLY"
    effective_date = "2022-06-03T07:50:22Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "3e24ef81-c50b-4cc3-aad3-d51f859c6a81@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
