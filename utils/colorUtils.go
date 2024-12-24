package utils

import (
	"fmt"
	"image"
	"os"

	colorkit "github.com/gookit/color"

	"github.com/cenkalti/dominantcolor"
)

func ExtractDominantColors(fileInput string, count int) ([]string, error) {
	img, err := loadImage(fileInput)
	if err != nil {
		return nil, fmt.Errorf("failed to load image: %w", err)
	}

	return extractColors(img, count), nil
}

func loadImage(fileInput string) (image.Image, error) {
	f, err := os.Open(fileInput)
	if err != nil {
		return nil, fmt.Errorf("failed to open file: %w", err)
	}
	defer f.Close()

	img, _, err := image.Decode(f)
	if err != nil {
		return nil, fmt.Errorf("failed to decode image: %w", err)
	}

	return img, nil
}

func extractColors(img image.Image, count int) []string {
	var dominantColors []string
	for _, color := range dominantcolor.FindN(img, count) {
		dominantColors = append(dominantColors, dominantcolor.Hex(color))
	}
	return dominantColors
}

func ExtractColors(fileInput string, count int) ([]string, error) {
	fallBackColors := []string{"#ffffff", "#000000", "00ffff", "0f0f0f", "#ffffff", "#000000", "00ffff", "0f0f0f"}
	colors, err := ExtractDomiantColors(fileInput, count)
	if err != nil {
		return fallBackColors, err
	}
	if len(colors) != count {
		colors = append(colors, fallBackColors...)
	}
	fmt.Println("Extracted colors:", colors)
	return colors[:count], nil
}

func SaveColors(colorList []string, filepath ...string) (string, error) {
	var filename string
	if len(filepath) > 0 {
		filename = filepath[0]
	} else {
		filename = "colors"
	}

	file, err := os.Create(filename)
	if err != nil {
		return filename, err
	}
	defer file.Close()

	file.WriteString("#!/bin/bash \n")
	fmt.Println("━━━━━━━━━━Color Sample Pallete━━━━━━━━━━")
	for i, color := range colorList {
		colorkit.Hex(color).Printf("┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃┃\n")
		line := fmt.Sprintf("COLOR_%d=0x%s\n", i+1, color[1:])
		_, err := file.WriteString(line)
		if err != nil {
			fmt.Println("Error writing to file:", err)
		}
	}
	fmt.Println("\n━━━━━━━━━━Color Sample Pallete━━━━━━━━━━")

	return filename, nil
}
