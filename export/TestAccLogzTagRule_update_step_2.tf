

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211210024743001283"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1210024743001283"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-13T00:00:00Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "ef6eeb1f-9d58-4eee-94c5-8c13b8856087@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_logz_tag_rule" "test" {
  logz_monitor_id = azurerm_logz_monitor.test.id
  tag_filter {
    name   = "ccc"
    action = "Include"
    value  = "ccc"
  }

  tag_filter {
    name   = "bbb"
    action = "Exclude"
    value  = ""
  }

  tag_filter {
    name   = "ccc"
    action = "Include"
    value  = "ccc"
  }
  send_aad_logs          = true
  send_activity_logs     = true
  send_subscription_logs = true
}
