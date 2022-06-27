


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220627131421466895"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0627131421466895"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-06-27T20:14:21Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "698c3135-4271-4f90-b0f7-642782efa48c@example.com"
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
    billing_cycle  = "MONTHLY"
    effective_date = "2022-06-27T20:14:21Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "698c3135-4271-4f90-b0f7-642782efa48c@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
