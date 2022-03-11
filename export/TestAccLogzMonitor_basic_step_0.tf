

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220311042636332164"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0311042636332164"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-03-11T11:26:36Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "00561bed-3d98-4fe3-923d-2666f30b25f0@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
