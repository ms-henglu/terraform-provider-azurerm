

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220218070939000089"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0218070939000089"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-02-18T14:09:39Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "c0496d27-7c45-44b2-8c64-7f713610e9a2@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
