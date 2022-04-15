

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220415030728119254"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0415030728119254"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  company_name      = "company-name-1"
  enterprise_app_id = "e081a27c-bc01-4159-bc06-7f9f711e3b3a"
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-04-15T10:07:28Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "c690b35c-3674-47cd-b5dc-b89238ae9c19@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
  enabled = false
  tags = {
    ENV = "Test"
  }
}
