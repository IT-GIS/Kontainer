package jobs

import (
	"fmt"
	"regexp"
	"strings"
	"time"
)

var containerPattern = regexp.MustCompile(`^[A-Z]{4}[0-9]{7}$`)

func ValidateContainerNumber(raw string) ContainerValidation {
	containerNo := strings.ToUpper(strings.ReplaceAll(strings.TrimSpace(raw), " ", ""))
	result := ContainerValidation{ContainerNo: containerNo, CheckDigitStatus: "invalid"}
	if len(containerNo) >= 4 {
		result.OwnerCode = containerNo[:3]
		result.EquipmentIdentifier = containerNo[3:4]
	}
	if len(containerNo) >= 10 {
		result.SerialNumber = containerNo[4:10]
	}
	if len(containerNo) >= 11 {
		result.CheckDigit = containerNo[10:11]
	}
	result.IsFormatValid = containerPattern.MatchString(containerNo)
	if !result.IsFormatValid {
		return result
	}
	result.IsCheckDigitValid = calculateCheckDigit(containerNo[:10]) == int(containerNo[10]-'0')
	if result.IsCheckDigitValid {
		result.CheckDigitStatus = "valid"
	}
	return result
}

func calculateCheckDigit(prefix string) int {
	alphabet := map[rune]int{}
	value := 10
	for ch := 'A'; ch <= 'Z'; ch++ {
		for value == 11 || value == 22 || value == 33 {
			value++
		}
		alphabet[ch] = value
		value++
	}
	sum := 0
	weight := 1
	for _, ch := range prefix {
		var n int
		if ch >= '0' && ch <= '9' {
			n = int(ch - '0')
		} else {
			n = alphabet[ch]
		}
		sum += n * weight
		weight *= 2
	}
	check := sum % 11
	if check == 10 {
		return 0
	}
	return check
}

func nextNumber(prefix string, count int) string {
	year := time.Now().UTC().Year()
	return fmt.Sprintf("GIFT-%s-%d-%06d", prefix, year, count+1)
}
