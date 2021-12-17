

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211217035458113893"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1217035458113893"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-17T10:54:58Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "e231d56d-b805-45c5-897f-99dd64237ee1@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
