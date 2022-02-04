

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220204060247982886"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0204060247982886"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-02-04T13:02:47Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "a1f3c3d1-0e81-4b2e-85b4-f2846fdbbd91@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
