package main
import (
	"fmt"
	"time"
)
func main() {
	for {
		fmt.Println("App running")
		time.Sleep(5 * time.Second)
	}
}
