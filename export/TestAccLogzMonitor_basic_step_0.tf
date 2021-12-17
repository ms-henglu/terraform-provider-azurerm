

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211217075446885184"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1217075446885184"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-17T14:54:46Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "3f967035-7ba3-4bcd-8a9c-67b726d68b1f@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
