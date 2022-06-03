
provider "azurerm" {
  features {}
}

data "azurerm_billing_enrollment_account_scope" "test" {
  billing_account    = "ARM_BILLING_ACCOUNT"
  enrollment_account = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-220603022749567108"
  subscription_name = "testAccSubscription 220603022749567108"
  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.test.id
}
