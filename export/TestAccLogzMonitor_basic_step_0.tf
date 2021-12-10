

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211210024743002952"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1210024743002952"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-10T09:47:43Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "fc31f06d-0019-48df-9e56-ad6a87b3f0d7@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
