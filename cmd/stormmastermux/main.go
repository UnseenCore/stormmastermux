package main

import (
	"log"

	"stormmastermux/internal/config"
	"stormmastermux/internal/router"
	"stormmastermux/internal/server"
)

func main() {
	cfg, err := config.Load("configs/config.toml")
	if err != nil {
		log.Fatal(err)
	}

	r := router.New(cfg)

	s := server.New(cfg, r)

	log.Println("StormMasterMux starting...")

	if err := s.Start(); err != nil {
		log.Fatal(err)
	}
}