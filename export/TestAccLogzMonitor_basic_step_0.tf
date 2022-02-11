

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220211130821765343"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0211130821765343"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-02-11T20:08:21Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "0bd88a3d-2fc9-4c73-8f89-139d3d5a99ad@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
