


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220114064326002332"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0114064326002332"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-17T00:00:00Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "93d1aa20-f639-4fa4-b71d-62b8b1031eb8@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_logz_tag_rule" "test" {
  logz_monitor_id = azurerm_logz_monitor.test.id
}


resource "azurerm_logz_tag_rule" "import" {
  logz_monitor_id = azurerm_logz_tag_rule.test.logz_monitor_id
}
