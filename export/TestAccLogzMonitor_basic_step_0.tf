

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220124125306027539"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0124125306027539"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-24T19:53:06Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "00843859-784e-4a86-9fcf-ca0884800953@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
