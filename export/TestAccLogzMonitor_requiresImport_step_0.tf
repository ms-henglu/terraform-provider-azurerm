

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-220225034623622676"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "liftr_test_only_0225034623622676"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "Monthly"
    effective_date = "2022-02-25T10:46:23Z"
    plan_id        = "100gb14days"
    usage_type     = "Committed"
  }

  user {
    email        = "c09a089e-d4d0-4895-a91b-b661ca3b2287@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
