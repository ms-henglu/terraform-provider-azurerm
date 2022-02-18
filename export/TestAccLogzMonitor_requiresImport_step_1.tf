


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220218070939002052"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0218070939002052"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-02-18T14:09:39Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "dbd86391-180a-48fc-b10c-8e30cc9d6c48@example.com"
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
    effective_date = "2022-02-18T14:09:39Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "dbd86391-180a-48fc-b10c-8e30cc9d6c48@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
