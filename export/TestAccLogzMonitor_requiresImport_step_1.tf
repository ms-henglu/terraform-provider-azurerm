


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220128082619359830"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0128082619359830"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-28T15:26:19Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "8854f7b2-be17-48b8-85b6-e2bea1a1af83@example.com"
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
    effective_date = "2022-01-28T15:26:19Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "8854f7b2-be17-48b8-85b6-e2bea1a1af83@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
