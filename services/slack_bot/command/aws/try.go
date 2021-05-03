package main

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	apex "github.com/apex/go-apex"
	"github.com/apex/go-apex/kinesis"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

const statsTableName = "test"

type payload struct {
	Event     string `json:"event"`
	Timestamp string `json:"timestamp"`
}

type aggregate struct {
	Name         string
	HourlyBucket int64
}

func main() {
	svc := dynamodb.New(session.New())

	kinesis.HandleFunc(func(event *kinesis.Event, ctx *apex.Context) error {
		stats := map[aggregate]int{}

		for _, r := range event.Records {
			// unmarshal data
			var p payload
			err := json.Unmarshal(r.Kinesis.Data, &p)
			if err != nil {
				log.Printf("json unmarshal error: %v", err)
				return err
			}

			// parse timestamp
			hts, err := hourlyTS(p.Timestamp)
			if err != nil {
				log.Printf("timestamp conv error: %v", err)
				return err
			}

			// increment coutner
			stat := aggregate{Name: p.Event, HourlyBucket: hts}
			stats[stat]++
		}

		// increment hourly ctrs in DDB
		for stat, count := range stats {
			err := saveStats(svc, stat, count)
			if err != nil {
				log.Printf("update item error: %v", err)
				return err
			}
		}

		return nil
	})
}

// hourlyTS takes a string timestamp in RFC3339 format, trims it down to
// nearest hour and returns Unix version of timestamp
func hourlyTS(s string) (int64, error) {
	ts, err := time.Parse(time.RFC3339, s)
	if err != nil {
		return 0, fmt.Errorf("parse time error: %v", err)
	}
	ts = time.Date(ts.Year(), ts.Month(), ts.Day(), ts.Hour(), 0, 0, 0, ts.Location())
	return ts.Unix(), nil
}

func saveStats(svc *dynamodb.DynamoDB, stat aggregate, count int) error {
	// removed DDB syntax for brevity
	return nil
}
