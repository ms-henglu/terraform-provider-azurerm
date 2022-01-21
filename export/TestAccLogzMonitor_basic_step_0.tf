

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220121044702888892"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0121044702888892"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-21T11:47:02Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "6e7b80a3-d6f6-4347-8992-3608b86b8972@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
