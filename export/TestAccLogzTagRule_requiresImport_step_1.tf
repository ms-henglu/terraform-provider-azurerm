


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220610022754973083"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0610022754973083"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-06-13T00:00:00Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "303ff915-824c-4fde-bb27-a7d961bbc999@example.com"
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
