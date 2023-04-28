
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name = "TestAcc-Deployment-230428050439835404"
}

data "azurerm_template_spec_version" "test" {
  name                = "acctest-standing-data-empty"
  resource_group_name = "standing-data-for-acctest"
  version             = "v1.0.0"
}

resource "azurerm_management_group_template_deployment" "test" {
  name                = "acctestMGdeploy-230428050439835404"
  management_group_id = azurerm_management_group.test.id
  location            = "West Europe"

  template_spec_version_id = data.azurerm_template_spec_version.test.id

}
