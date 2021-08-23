package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
	"github.com/spiffe/go-spiffe/v2/workloadapi"

	kafka "github.com/segmentio/kafka-go"

	uuidLib "github.com/google/uuid"
)

func main() {
	// Get environment vars
	spiffeTrustDomain, ok := os.LookupEnv("SPIFFE_TRUST_DOMAIN")
	if !ok {
		log.Fatal("env SPIFFE_TRUST_DOMAIN is not set")
	}
	kafkaID, ok := os.LookupEnv("KAFKA_ID")
	if !ok {
		log.Fatal("env KAFKA_ID is not set")
	}
	workloadAPISocketPath, ok := os.LookupEnv("WORKLOAD_API_SOCK_PATH")
	if !ok {
		log.Fatal("env WORKLOAD_API_SOCK_PATH is not set")
	}
	brokerAddr, ok := os.LookupEnv("BROKER_ADDR")
	if !ok {
		log.Fatal("env BROKER_ADDR is not set")
	}
	topicName, ok := os.LookupEnv("TOPIC")
	if !ok {
		log.Fatal("env TOPIC is not set")
	}

	// Allowed SPIFFE ID
	spiffeID := spiffeid.Must(spiffeTrustDomain, kafkaID)

	// Setup context
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	// Setup Workload API
	source, err := workloadapi.NewX509Source(ctx, workloadapi.WithClientOptions(workloadapi.WithAddr(workloadAPISocketPath)))
	if err != nil {
		log.Fatalf("Unable to create X509Source %v", err)
	}
	defer source.Close()

	// SPIFFE-TLS config
	tlsConfig := tlsconfig.MTLSClientConfig(source, source, tlsconfig.AuthorizeID(spiffeID))

	// TLS dialer
	dialer := &kafka.Dialer{
		Timeout:   10 * time.Second,
		DualStack: true,
		TLS:       tlsConfig,
	}

	// Configure kafka producer
	writer := kafka.NewWriter(kafka.WriterConfig{
		Brokers:  []string{brokerAddr},
		Topic:    topicName,
		Balancer: &kafka.Hash{},
		Dialer:   dialer,
	})
	defer writer.Close()

	fmt.Println("start producing ... !!")
	for i := 0; ; i++ {
		uuid := uuidLib.New()
		msg := kafka.Message{
			Value: []byte(fmt.Sprint(uuid)),
		}
		err := writer.WriteMessages(context.Background(), msg)
		if err != nil {
			fmt.Println("failed to write messages:", err)
		} else {
			fmt.Println("produced", uuid)
		}
		time.Sleep(2 * time.Second)
	}
}
