

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220128082619350177"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0128082619350177"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-28T15:26:19Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "8bb2dfec-e54e-44f0-97cf-9e3497028af3@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
