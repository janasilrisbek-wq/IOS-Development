import Foundation

// Assignment 2 · Working with Collections in Swift
// Author: Zhanassyl Rysbek
// No loops and no if/else are used in this file.

// MARK: - Easy

// 1. Array creation and access
let fruits = ["apple", "banana", "mango", "kiwi", "pomegranate"]
print("Third fruit:", fruits[2])

// 2. Set creation and manipulation
var favoriteNumbers: Set<Int> = [3, 7, 14, 21]
favoriteNumbers.insert(42)
print("Favorite numbers:", favoriteNumbers.sorted())

// 3. Dictionary creation and access
let releaseYears: [String: Int] = ["Swift": 2014, "Python": 1991, "JavaScript": 1995]
print("Swift was released in", releaseYears["Swift", default: 0])

// 4. Array element update
var colors = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print("Colors:", colors)

// MARK: - Medium

// 1. Set intersection
let firstSet: Set<Int> = [1, 2, 3, 4]
let secondSet: Set<Int> = [3, 4, 5, 6]
print("Intersection:", firstSet.intersection(secondSet).sorted())

// 2. Dictionary update
var scores: [String: Int] = ["Aruzhan": 85, "Dias": 72, "Madina": 90]
scores.updateValue(80, forKey: "Dias")
print("Scores:", scores)

// 3. Array merge
let firstFruits = ["apple", "banana"]
let secondFruits = ["cherry", "date"]
let mergedFruits = firstFruits + secondFruits
print("Merged:", mergedFruits)

// MARK: - Hard

// 1. Dictionary key addition
var populations: [String: Int] = [
    "Kazakhstan": 20_300_000,
    "Uzbekistan": 37_000_000,
    "Kyrgyzstan": 7_200_000
]
populations["Tajikistan"] = 10_300_000
print("Populations:", populations)

// 2. Set union and subtract
let pets: Set<String> = ["cat", "dog"]
let otherPets: Set<String> = ["dog", "mouse"]
let unionPets = pets.union(otherPets)
let finalPets = unionPets.subtracting(otherPets)
print("Union:", unionPets.sorted(), "→ after subtracting:", finalPets.sorted())

// 3. Nested collection
let grades: [String: [Int]] = [
    "Zhanassyl": [90, 85, 95],
    "Aigerim": [78, 88, 92],
    "Timur": [70, 80, 75]
]
print("Zhanassyl's second grade:", grades["Zhanassyl", default: []].dropFirst().first ?? 0)
