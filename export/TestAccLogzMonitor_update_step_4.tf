

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211217075446880091"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_1217075446880091"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-12-17T14:54:46Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "b9e4dcd0-aa90-4ca4-80ca-9f49737c13a7@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
