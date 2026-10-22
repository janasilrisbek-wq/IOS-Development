import Foundation

// Assignment 1 · Your Life Story in Swift
// Author: Zhanassyl Rysbek

// MARK: - Step 1 · Personal information

let firstName: String = "Zhanassyl"
let lastName: String = "Rysbek"
let birthYear: Int = 2004
let currentYear: Int = 2026
var age: Int = currentYear - birthYear          // Bonus: age calculated from birthYear
var isStudent: Bool = true
var height: Double = 1.78                       // meters
let hometown: String = "Tülkibas, South Kazakhstan"
var city: String = "Almaty"
var university: String = "KBTU"
var major: String = "Information Systems"
var yearOfStudy: Int = 3
var graduationYear: Int = 2027

// MARK: - Step 2 · Hobbies and interests

var hobby: String = "filmmaking"
var otherHobbies: String = "drone videography, 3D modeling in Blender and content creation"
var numberOfHobbies: Int = 4
var favoriteNumber: Int = 7
var isHobbyCreative: Bool = true
var favoriteLanguage: String = "Swift"

// Emoji as values and as variable names
let 🎬 = "🎥"
let 🚁 = "🛸"
let 💻 = "Swift 🧡"

// MARK: - Bonus · Future goals

var futureGoals: String = "In the future, I want to become a professional iOS developer and build apps that look as good as the videos I shoot."

// MARK: - Step 3 · Summary with string interpolation

let studentText = isStudent ? "I am currently a student" : "I am not a student right now"
let creativeText = isHobbyCreative ? "which is a creative hobby" : "which is not really a creative hobby"

var lifeStory = "My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). "
lifeStory += "I come from \(hometown) and now live in \(city). "
lifeStory += "\(studentText): \(yearOfStudy)rd-year \(major) at \(university), graduating in \(graduationYear). "
lifeStory += "I am \(height) m tall. "
lifeStory += "I enjoy \(hobby) \(🎬), \(creativeText). I also like \(otherHobbies) \(🚁). "
lifeStory += "I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber). "
lifeStory += "My favorite programming language this semester is \(💻). "
lifeStory += futureGoals

// MARK: - Step 4 · Print

print(lifeStory)
