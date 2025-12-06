// Q11 - sun-cipher application
// A simple Go application that outputs a cipher message

package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {
	// Print startup message
	fmt.Println("sun-cipher started")
	fmt.Printf("Timestamp: %s\n", time.Now().Format(time.RFC3339))
	fmt.Println("Secret cipher: SUN-CIPHER-CKAD-2024")

	// Start HTTP server on port 80
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "sun-cipher is running\n")
		fmt.Fprintf(w, "Secret: SUN-CIPHER-CKAD-2024\n")
	})

	fmt.Println("Starting HTTP server on :80")
	if err := http.ListenAndServe(":80", nil); err != nil {
		fmt.Printf("Server error: %v\n", err)
	}
}
