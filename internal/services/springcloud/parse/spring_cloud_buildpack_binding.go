package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/hashicorp/go-azure-helpers/resourcemanager/resourceids"
)

type SpringCloudBuildpackBindingId struct {
	SubscriptionId       string
	ResourceGroup        string
	SpringName           string
	BuildServiceName     string
	BuilderName          string
	BuildpackBindingName string
}

func NewSpringCloudBuildpackBindingID(subscriptionId, resourceGroup, springName, buildServiceName, builderName, buildpackBindingName string) SpringCloudBuildpackBindingId {
	return SpringCloudBuildpackBindingId{
		SubscriptionId:       subscriptionId,
		ResourceGroup:        resourceGroup,
		SpringName:           springName,
		BuildServiceName:     buildServiceName,
		BuilderName:          builderName,
		BuildpackBindingName: buildpackBindingName,
	}
}

func (id SpringCloudBuildpackBindingId) String() string {
	segments := []string{
		fmt.Sprintf("Buildpack Binding Name %q", id.BuildpackBindingName),
		fmt.Sprintf("Builder Name %q", id.BuilderName),
		fmt.Sprintf("Build Service Name %q", id.BuildServiceName),
		fmt.Sprintf("Spring Name %q", id.SpringName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Spring Cloud Buildpack Binding", segmentsStr)
}

func (id SpringCloudBuildpackBindingId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.AppPlatform/Spring/%s/buildServices/%s/builders/%s/buildpackBindings/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.SpringName, id.BuildServiceName, id.BuilderName, id.BuildpackBindingName)
}

// SpringCloudBuildpackBindingID parses a SpringCloudBuildpackBinding ID into an SpringCloudBuildpackBindingId struct
func SpringCloudBuildpackBindingID(input string) (*SpringCloudBuildpackBindingId, error) {
	id, err := resourceids.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := SpringCloudBuildpackBindingId{
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
	if resourceId.BuilderName, err = id.PopSegment("builders"); err != nil {
		return nil, err
	}
	if resourceId.BuildpackBindingName, err = id.PopSegment("buildpackBindings"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}
