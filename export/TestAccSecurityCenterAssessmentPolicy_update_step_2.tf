
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_assessment_policy" "test" {
  display_name            = "Updated Test Display Name"
  severity                = "Medium"
  description             = "Updated Test Description"
  implementation_effort   = "Moderate"
  remediation_description = "Updated Test Remediation Description"
  threats                 = ["DataExfiltration", "DataSpillage"]
  user_impact             = "Moderate"
}
