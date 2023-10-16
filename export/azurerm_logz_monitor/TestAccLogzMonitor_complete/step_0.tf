

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-231016034213698403"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-231016034213698403"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  company_name      = "company-name-1"
  enterprise_app_id = "e081a27c-bc01-4159-bc06-7f9f711e3b3a"
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2023-10-16T10:42:13Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "37d395aa-4b30-4566-b141-72ea4bf84e11@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
  enabled = true
  tags = {
    ENV = "Test"
  }
}
