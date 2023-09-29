
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230929064313982554"
  location = "West Europe"
}


resource "azurerm_application_insights_workbook_template" "test" {
  name                = "acctest-aiwt-230929064313982554"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  author              = "test author"
  priority            = 1

  galleries {
    category      = "Failures"
    name          = "test"
    order         = 100
    resource_type = "microsoft.insights/components"
    type          = "tsg"
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

  localized = jsonencode({
    "ar" : [
      {
        "galleries" : [
          {
            "name" : "test",
            "category" : "Failures",
            "type" : "tsg",
            "resourceType" : "microsoft.insights/components",
            "order" : 100
          }
        ],
        "templateData" : {
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
        },
      }
    ]
  })

  tags = {
    key = "value"
  }
}
