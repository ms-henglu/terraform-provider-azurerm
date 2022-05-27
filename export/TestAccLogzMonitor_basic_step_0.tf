

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220527034347564113"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0527034347564113"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-05-27T10:43:47Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "0cbd9ef4-8e4f-4a92-b942-1bad5eafd3b6@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
