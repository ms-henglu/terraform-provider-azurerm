

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220107064258009768"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0107064258009768"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-07T13:42:58Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "6fa69dea-bdfc-42c3-8a91-e40dba5d526f@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
