package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"testing"

	"github.com/hashicorp/terraform-provider-azurerm/internal/resourceid"
)

var _ resourceid.Formatter = SensitivityLabelId{}

func TestSensitivityLabelIDFormatter(t *testing.T) {
	actual := NewSensitivityLabelID("12345678-1234-9876-4563-123456789012", "resGroup1", "workspace1", "sqlPool1", "schema1", "table1", "column1", "label1").ID()
	expected := "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/schema1/tables/table1/columns/column1/sensitivityLabels/label1"
	if actual != expected {
		t.Fatalf("Expected %q but got %q", expected, actual)
	}
}

func TestSensitivityLabelID(t *testing.T) {
	testData := []struct {
		Input    string
		Error    bool
		Expected *SensitivityLabelId
	}{

		{
			// empty
			Input: "",
			Error: true,
		},

		{
			// missing SubscriptionId
			Input: "/",
			Error: true,
		},

		{
			// missing value for SubscriptionId
			Input: "/subscriptions/",
			Error: true,
		},

		{
			// missing ResourceGroup
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/",
			Error: true,
		},

		{
			// missing value for ResourceGroup
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/",
			Error: true,
		},

		{
			// missing WorkspaceName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/",
			Error: true,
		},

		{
			// missing value for WorkspaceName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/",
			Error: true,
		},

		{
			// missing SqlPoolName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/",
			Error: true,
		},

		{
			// missing value for SqlPoolName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/",
			Error: true,
		},

		{
			// missing SchemaName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/",
			Error: true,
		},

		{
			// missing value for SchemaName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/",
			Error: true,
		},

		{
			// missing TableName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/schema1/",
			Error: true,
		},

		{
			// missing value for TableName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/schema1/tables/",
			Error: true,
		},

		{
			// missing ColumnName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/schema1/tables/table1/",
			Error: true,
		},

		{
			// missing value for ColumnName
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/schema1/tables/table1/columns/",
			Error: true,
		},

		{
			// missing Name
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/schema1/tables/table1/columns/column1/",
			Error: true,
		},

		{
			// missing value for Name
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/schema1/tables/table1/columns/column1/sensitivityLabels/",
			Error: true,
		},

		{
			// valid
			Input: "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Synapse/workspaces/workspace1/sqlPools/sqlPool1/schemas/schema1/tables/table1/columns/column1/sensitivityLabels/label1",
			Expected: &SensitivityLabelId{
				SubscriptionId: "12345678-1234-9876-4563-123456789012",
				ResourceGroup:  "resGroup1",
				WorkspaceName:  "workspace1",
				SqlPoolName:    "sqlPool1",
				SchemaName:     "schema1",
				TableName:      "table1",
				ColumnName:     "column1",
				Name:           "label1",
			},
		},

		{
			// upper-cased
			Input: "/SUBSCRIPTIONS/12345678-1234-9876-4563-123456789012/RESOURCEGROUPS/RESGROUP1/PROVIDERS/MICROSOFT.SYNAPSE/WORKSPACES/WORKSPACE1/SQLPOOLS/SQLPOOL1/SCHEMAS/SCHEMA1/TABLES/TABLE1/COLUMNS/COLUMN1/SENSITIVITYLABELS/LABEL1",
			Error: true,
		},
	}

	for _, v := range testData {
		t.Logf("[DEBUG] Testing %q", v.Input)

		actual, err := SensitivityLabelID(v.Input)
		if err != nil {
			if v.Error {
				continue
			}

			t.Fatalf("Expect a value but got an error: %s", err)
		}
		if v.Error {
			t.Fatal("Expect an error but didn't get one")
		}

		if actual.SubscriptionId != v.Expected.SubscriptionId {
			t.Fatalf("Expected %q but got %q for SubscriptionId", v.Expected.SubscriptionId, actual.SubscriptionId)
		}
		if actual.ResourceGroup != v.Expected.ResourceGroup {
			t.Fatalf("Expected %q but got %q for ResourceGroup", v.Expected.ResourceGroup, actual.ResourceGroup)
		}
		if actual.WorkspaceName != v.Expected.WorkspaceName {
			t.Fatalf("Expected %q but got %q for WorkspaceName", v.Expected.WorkspaceName, actual.WorkspaceName)
		}
		if actual.SqlPoolName != v.Expected.SqlPoolName {
			t.Fatalf("Expected %q but got %q for SqlPoolName", v.Expected.SqlPoolName, actual.SqlPoolName)
		}
		if actual.SchemaName != v.Expected.SchemaName {
			t.Fatalf("Expected %q but got %q for SchemaName", v.Expected.SchemaName, actual.SchemaName)
		}
		if actual.TableName != v.Expected.TableName {
			t.Fatalf("Expected %q but got %q for TableName", v.Expected.TableName, actual.TableName)
		}
		if actual.ColumnName != v.Expected.ColumnName {
			t.Fatalf("Expected %q but got %q for ColumnName", v.Expected.ColumnName, actual.ColumnName)
		}
		if actual.Name != v.Expected.Name {
			t.Fatalf("Expected %q but got %q for Name", v.Expected.Name, actual.Name)
		}
	}
}
