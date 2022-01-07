

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220107034120342153"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0107034120342153"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-07T10:41:20Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "153e401e-d875-48f2-9cb4-89de7899a653@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
