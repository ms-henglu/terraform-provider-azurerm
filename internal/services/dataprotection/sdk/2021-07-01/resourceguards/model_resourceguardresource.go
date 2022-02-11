package resourceguards

type ResourceGuardResource struct {
	ETag       *string             `json:"eTag,omitempty"`
	Id         *string             `json:"id,omitempty"`
	Identity   *DppIdentityDetails `json:"identity,omitempty"`
	Location   *string             `json:"location,omitempty"`
	Name       *string             `json:"name,omitempty"`
	Properties *ResourceGuard      `json:"properties,omitempty"`
	SystemData *SystemData         `json:"systemData,omitempty"`
	Tags       *map[string]string  `json:"tags,omitempty"`
	Type       *string             `json:"type,omitempty"`
}
