

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220121044702886230"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0121044702886230"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-21T11:47:02Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "145f1d70-05a4-4865-a7ed-13d2de31ee00@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
