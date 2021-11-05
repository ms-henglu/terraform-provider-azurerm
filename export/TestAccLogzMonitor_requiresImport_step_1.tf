


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-211105040106362980"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-211105040106362980"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2021-11-05T11:01:06Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "e081a27c-bc01-4159-bc06-7f9f711e3b3a@example.com"
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
    effective_date = "2021-11-05T11:01:06Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "e081a27c-bc01-4159-bc06-7f9f711e3b3a@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
