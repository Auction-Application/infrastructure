package main

import (
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(PollMultiPartCompletionEvent)
}

func PollMultiPartCompletionEvent(event events.SQSEvent) error {
	fmt.Println(event)
	for _, record := range event.Records {
		fmt.Println(record)
		err := processMessage(record)
		if err != nil {
			return err
		}
	}
	fmt.Println("done")
	return nil
}

func processMessage(record events.SQSMessage) error {
	fmt.Printf("Processed message %s\n", record.Body)
	// TODO: Do interesting work based on the new message
	return nil
}
