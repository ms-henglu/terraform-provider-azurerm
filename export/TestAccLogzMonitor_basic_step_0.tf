

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220114064326009090"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0114064326009090"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-14T13:43:26Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "63a03af6-cbf2-488d-96d2-efed93cfd9f0@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
