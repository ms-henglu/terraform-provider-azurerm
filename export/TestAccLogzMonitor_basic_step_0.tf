

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220114014426695052"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0114014426695052"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-14T08:44:26Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "8a74af24-6ef3-4814-9d6c-9a86da8c4f01@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
