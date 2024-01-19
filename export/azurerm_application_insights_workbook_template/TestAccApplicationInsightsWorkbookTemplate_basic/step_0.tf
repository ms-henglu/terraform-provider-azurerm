
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119024426261339"
  location = "West Europe"
}


resource "azurerm_application_insights_workbook_template" "test" {
  name                = "acctest-aiwt-240119024426261339"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"

  galleries {
    category = "workbook"
    name     = "test"
  }

  template_data = jsonencode({
    "version" : "Notebook/1.0",
    "items" : [
      {
        "type" : 1,
        "content" : {
          "json" : "## New workbook\n---\n\nWelcome to your new workbook."
        },
        "name" : "text - 2"
      }
    ],
    "styleSettings" : {},
    "$schema" : "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })
}
