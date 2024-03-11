
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311031249561332"
  location = "West Europe"
}


resource "azurerm_application_insights_workbook" "test" {
  name                = "be1ad266-d329-4454-b693-8287e4d3b35d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  display_name        = "acctest-amw-240311031249561332"
  data_json = jsonencode({
    "version" = "Notebook/1.0",
    "items" = [
      {
        "type" = 1,
        "content" = {
          "json" = "Test2022"
        },
        "name" = "text - 0"
      }
    ],
    "isLocked" = false,
    "fallbackResourceIds" = [
      "Azure Monitor"
    ]
  })
}


resource "azurerm_application_insights_workbook" "import" {
  name                = azurerm_application_insights_workbook.test.name
  resource_group_name = azurerm_application_insights_workbook.test.resource_group_name
  location            = azurerm_application_insights_workbook.test.location
  category            = azurerm_application_insights_workbook.test.category
  display_name        = azurerm_application_insights_workbook.test.display_name
  source_id           = azurerm_application_insights_workbook.test.source_id
  data_json           = azurerm_application_insights_workbook.test.data_json
}
