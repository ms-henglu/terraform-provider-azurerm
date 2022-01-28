

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220128052724780384"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0128052724780384"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-28T12:27:24Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "f241c4fe-106e-4072-b70c-d3afb65aa65e@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
