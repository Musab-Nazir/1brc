package main

import (
	"io/ioutil"
	"log"
	"strconv"
	"strings"
	"time"
)

func main() {
	time1 := time.Now()
	b, err := ioutil.ReadFile("measurements.txt")
	if err != nil {
		log.Fatal("couldn't read file", err)
	}

	strInput := string(b)
	diff := time.Now().Sub(time1)
	lines := strings.Split(strInput, "\n")
	dict := make(map[string][]float32)
	time2 := time.Now()
	for _, line := range lines {
		splits := strings.Split(line, ";")
		if len(splits) == 2 {
			v, err := strconv.ParseFloat(splits[1], 32)
			if err != nil {
				log.Fatal("Float parsing failed", err)
			}
			addToDict(dict, splits[0], float32(v))
		}
	}
	diff2 := time.Now().Sub(time2)
	log.Println("Dict length: %d", len(dict))
	log.Println("File read in: %s", diff)
	log.Println("File parsed in: %s", diff2)
}

func addToDict(d map[string][]float32, k string, v float32) {
	if d[k] != nil {
		d[k] = append(d[k], v)
	} else {
		d[k] = []float32{v}
	}
}
