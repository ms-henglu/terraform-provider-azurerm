package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/hashicorp/go-azure-helpers/resourcemanager/resourceids"
)

type SpringCloudBuildServiceBuildResultId struct {
	SubscriptionId   string
	ResourceGroup    string
	SpringName       string
	BuildServiceName string
	BuildName        string
	ResultName       string
}

func NewSpringCloudBuildServiceBuildResultID(subscriptionId, resourceGroup, springName, buildServiceName, buildName, resultName string) SpringCloudBuildServiceBuildResultId {
	return SpringCloudBuildServiceBuildResultId{
		SubscriptionId:   subscriptionId,
		ResourceGroup:    resourceGroup,
		SpringName:       springName,
		BuildServiceName: buildServiceName,
		BuildName:        buildName,
		ResultName:       resultName,
	}
}

func (id SpringCloudBuildServiceBuildResultId) String() string {
	segments := []string{
		fmt.Sprintf("Result Name %q", id.ResultName),
		fmt.Sprintf("Build Name %q", id.BuildName),
		fmt.Sprintf("Build Service Name %q", id.BuildServiceName),
		fmt.Sprintf("Spring Name %q", id.SpringName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Spring Cloud Build Service Build Result", segmentsStr)
}

func (id SpringCloudBuildServiceBuildResultId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.AppPlatform/Spring/%s/buildServices/%s/builds/%s/results/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.SpringName, id.BuildServiceName, id.BuildName, id.ResultName)
}

// SpringCloudBuildServiceBuildResultID parses a SpringCloudBuildServiceBuildResult ID into an SpringCloudBuildServiceBuildResultId struct
func SpringCloudBuildServiceBuildResultID(input string) (*SpringCloudBuildServiceBuildResultId, error) {
	id, err := resourceids.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := SpringCloudBuildServiceBuildResultId{
		SubscriptionId: id.SubscriptionID,
		ResourceGroup:  id.ResourceGroup,
	}

	if resourceId.SubscriptionId == "" {
		return nil, fmt.Errorf("ID was missing the 'subscriptions' element")
	}

	if resourceId.ResourceGroup == "" {
		return nil, fmt.Errorf("ID was missing the 'resourceGroups' element")
	}

	if resourceId.SpringName, err = id.PopSegment("Spring"); err != nil {
		return nil, err
	}
	if resourceId.BuildServiceName, err = id.PopSegment("buildServices"); err != nil {
		return nil, err
	}
	if resourceId.BuildName, err = id.PopSegment("builds"); err != nil {
		return nil, err
	}
	if resourceId.ResultName, err = id.PopSegment("results"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}
