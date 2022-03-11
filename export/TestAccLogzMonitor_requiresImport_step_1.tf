


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220311042636339973"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0311042636339973"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-03-11T11:26:36Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "f097cc65-0df8-4265-9433-8589e6b928e6@example.com"
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
    effective_date = "2022-03-11T11:26:36Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "f097cc65-0df8-4265-9433-8589e6b928e6@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
