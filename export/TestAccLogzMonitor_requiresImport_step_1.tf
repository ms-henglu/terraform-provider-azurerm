


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220107064258017206"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0107064258017206"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-07T13:42:58Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "28031958-92b8-4de8-8e64-39cfbc60fe76@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_logz_monitor" "import" {
  name                = azurerm_logz_monitor.test.name
  resource_group_name = azurerm_logz_monitor.test.resource_group_name
  location            = azurerm_logz_monitor.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-07T13:42:58Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "28031958-92b8-4de8-8e64-39cfbc60fe76@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
