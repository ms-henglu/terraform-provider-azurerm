

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220121044702884019"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0121044702884019"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  company_name      = "company-name-1"
  enterprise_app_id = "e081a27c-bc01-4159-bc06-7f9f711e3b3a"
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-01-21T11:47:02Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "a52c70f1-9b1c-4aeb-a5ff-fcf2e16a23bf@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
  enabled = false
  tags = {
    ENV = "Test"
  }
}
