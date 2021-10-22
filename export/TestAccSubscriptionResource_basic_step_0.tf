
provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account    = "ARM_BILLING_ACCOUNT"
  enrollment_account = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-211022002544133594"
  subscription_name = "testAccSubscription 211022002544133594"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
}
