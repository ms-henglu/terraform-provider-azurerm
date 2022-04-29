


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220429065713427191"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0429065713427191"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-04-29T13:57:13Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "2f9918ed-c5ee-4f36-86df-5ad9ea84ce6b@example.com"
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
    effective_date = "2022-04-29T13:57:13Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "2f9918ed-c5ee-4f36-86df-5ad9ea84ce6b@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
