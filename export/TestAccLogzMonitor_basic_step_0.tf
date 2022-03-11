

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220311032729733113"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0311032729733113"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-03-11T10:27:29Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "d2a0f4f2-76eb-4326-811c-44195b3fbbfa@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
