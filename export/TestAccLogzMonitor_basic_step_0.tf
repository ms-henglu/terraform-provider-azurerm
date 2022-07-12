

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220712042453771508"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-220712042453771508"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-07-12T11:24:53Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "9d186100-1e0f-4b4a-bb10-753d2d52b750@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
