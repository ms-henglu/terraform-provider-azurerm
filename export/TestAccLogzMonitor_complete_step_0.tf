

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220603005022660500"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0603005022660500"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  company_name      = "company-name-1"
  enterprise_app_id = "e081a27c-bc01-4159-bc06-7f9f711e3b3a"
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-06-03T07:50:22Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "fa0cda19-5143-4123-877a-ca9e0bdbb6f9@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
  enabled = false
  tags = {
    ENV = "Test"
  }
}
