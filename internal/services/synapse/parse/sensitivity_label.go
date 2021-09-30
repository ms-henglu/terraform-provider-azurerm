package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/hashicorp/terraform-provider-azurerm/helpers/azure"
)

type SensitivityLabelId struct {
	SubscriptionId string
	ResourceGroup  string
	WorkspaceName  string
	SqlPoolName    string
	SchemaName     string
	TableName      string
	ColumnName     string
	Name           string
}

func NewSensitivityLabelID(subscriptionId, resourceGroup, workspaceName, sqlPoolName, schemaName, tableName, columnName, name string) SensitivityLabelId {
	return SensitivityLabelId{
		SubscriptionId: subscriptionId,
		ResourceGroup:  resourceGroup,
		WorkspaceName:  workspaceName,
		SqlPoolName:    sqlPoolName,
		SchemaName:     schemaName,
		TableName:      tableName,
		ColumnName:     columnName,
		Name:           name,
	}
}

func (id SensitivityLabelId) String() string {
	segments := []string{
		fmt.Sprintf("Name %q", id.Name),
		fmt.Sprintf("Column Name %q", id.ColumnName),
		fmt.Sprintf("Table Name %q", id.TableName),
		fmt.Sprintf("Schema Name %q", id.SchemaName),
		fmt.Sprintf("Sql Pool Name %q", id.SqlPoolName),
		fmt.Sprintf("Workspace Name %q", id.WorkspaceName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Sensitivity Label", segmentsStr)
}

func (id SensitivityLabelId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Synapse/workspaces/%s/sqlPools/%s/schemas/%s/tables/%s/columns/%s/sensitivityLabels/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.WorkspaceName, id.SqlPoolName, id.SchemaName, id.TableName, id.ColumnName, id.Name)
}

// SensitivityLabelID parses a SensitivityLabel ID into an SensitivityLabelId struct
func SensitivityLabelID(input string) (*SensitivityLabelId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := SensitivityLabelId{
		SubscriptionId: id.SubscriptionID,
		ResourceGroup:  id.ResourceGroup,
	}

	if resourceId.SubscriptionId == "" {
		return nil, fmt.Errorf("ID was missing the 'subscriptions' element")
	}

	if resourceId.ResourceGroup == "" {
		return nil, fmt.Errorf("ID was missing the 'resourceGroups' element")
	}

	if resourceId.WorkspaceName, err = id.PopSegment("workspaces"); err != nil {
		return nil, err
	}
	if resourceId.SqlPoolName, err = id.PopSegment("sqlPools"); err != nil {
		return nil, err
	}
	if resourceId.SchemaName, err = id.PopSegment("schemas"); err != nil {
		return nil, err
	}
	if resourceId.TableName, err = id.PopSegment("tables"); err != nil {
		return nil, err
	}
	if resourceId.ColumnName, err = id.PopSegment("columns"); err != nil {
		return nil, err
	}
	if resourceId.Name, err = id.PopSegment("sensitivityLabels"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}
