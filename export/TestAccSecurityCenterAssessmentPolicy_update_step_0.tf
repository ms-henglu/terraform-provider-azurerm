
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_assessment_policy" "test" {
  display_name            = "Test Display Name"
  severity                = "Low"
  description             = "Test Description"
  implementation_effort   = "Low"
  remediation_description = "Test Remediation Description"
  threats                 = ["DataExfiltration", "DataSpillage", "MaliciousInsider"]
  user_impact             = "Low"
  categories              = ["Data"]
}
