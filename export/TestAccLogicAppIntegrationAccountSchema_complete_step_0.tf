

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-211001053911382516"
  location = "West Europe"
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctest-ia-211001053911382516"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_logic_app_integration_account_schema" "test" {
  name                     = "acctest-iaschema-211001053911382516"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name
  content                  = file("testdata/integration_account_schema_content.xsd")
  file_name                = "TestFile.xsd"

  metadata = <<METADATA
    {
        "foo": "bar"
    }
METADATA
}
