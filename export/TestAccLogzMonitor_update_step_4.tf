

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220204093213476411"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0204093213476411"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-02-04T16:32:13Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "fde4a8f7-ca24-4960-b2a2-52aa33d695c0@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
