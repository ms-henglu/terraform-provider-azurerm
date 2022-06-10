

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220610022754977381"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0610022754977381"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-06-13T00:00:00Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "4bdd6c5a-94f9-4546-8276-a0c2d9b58a52@example.com"
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
