


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220311032729731995"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0311032729731995"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-03-11T10:27:29Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "a971881d-9b26-4b06-a483-356364f1cb1e@example.com"
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
    effective_date = "2022-03-11T10:27:29Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "a971881d-9b26-4b06-a483-356364f1cb1e@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
