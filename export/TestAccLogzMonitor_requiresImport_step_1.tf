


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211217075446885942"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1217075446885942"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-17T14:54:46Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "9aad9e62-e2c6-40a9-b054-a15c4e46a069@example.com"
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
    effective_date = "2021-12-17T14:54:46Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "9aad9e62-e2c6-40a9-b054-a15c4e46a069@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
