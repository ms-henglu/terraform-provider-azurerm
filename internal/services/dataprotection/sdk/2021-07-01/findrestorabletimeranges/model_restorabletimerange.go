package findrestorabletimeranges

type RestorableTimeRange struct {
	EndTime    string  `json:"endTime"`
	ObjectType *string `json:"objectType,omitempty"`
	StartTime  string  `json:"startTime"`
}
