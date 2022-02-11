package findrestorabletimeranges

import "github.com/Azure/go-autorest/autorest"

type FindRestorableTimeRangesClient struct {
	Client  autorest.Client
	baseUri string
}

func NewFindRestorableTimeRangesClientWithBaseURI(endpoint string) FindRestorableTimeRangesClient {
	return FindRestorableTimeRangesClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}
