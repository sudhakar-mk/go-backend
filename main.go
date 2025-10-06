package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
)

type AddResp struct {
	A   int `json:"a"`
	B   int `json:"b"`
	Sum int `json:"sum"`
}

func add(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	a, _ := strconv.Atoi(q.Get("a"))
	b, _ := strconv.Atoi(q.Get("b"))
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(AddResp{A: a, B: b, Sum: a + b})
}

func main() {
	http.HandleFunc("/api/add", add)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Listening on :%s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
