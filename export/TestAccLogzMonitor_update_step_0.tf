

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220204060247988702"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0204060247988702"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-02-04T13:02:47Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "32916242-a38d-47ae-a3b8-cf5e17ed4e45@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
