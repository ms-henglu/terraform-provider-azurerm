
provider "azurerm" {
  features {}
}

data "azurerm_billing_mca_account_scope" "test" {
  billing_account_name = "ARM_BILLING_ACCOUNT"
  billing_profile_name = ""
  invoice_section_name = ""
}

resource "azurerm_subscription" "test" {
  alias             = "testAcc-231020042010126687"
  subscription_name = "testAccSubscription 231020042010126687"
  billing_scope_id  = data.azurerm_billing_mca_account_scope.test.id
}
