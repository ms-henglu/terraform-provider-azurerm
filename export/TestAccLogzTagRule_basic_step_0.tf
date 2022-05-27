

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220527034347568648"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0527034347568648"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-05-30T00:00:00Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "8ea3eb2e-3d16-4ad8-a387-5953b104c906@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_logz_tag_rule" "test" {
  logz_monitor_id = azurerm_logz_monitor.test.id
}
