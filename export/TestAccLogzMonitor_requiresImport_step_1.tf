


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220107034120346986"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0107034120346986"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-07T10:41:20Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "66b29b2e-327f-4444-9721-30a6402ddeff@example.com"
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
    effective_date = "2022-01-07T10:41:20Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "66b29b2e-327f-4444-9721-30a6402ddeff@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
