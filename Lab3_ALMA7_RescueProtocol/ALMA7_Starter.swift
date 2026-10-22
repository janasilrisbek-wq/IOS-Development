// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Author: Zhanassyl Rysbek


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP"
    else { return nil }
    return (sensor: parts.0, value: value)
}

print("--- 1.1 parseReading ---")
print(parseReading("O2:87") as Any)
print(parseReading("TEMP:-12") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

let parsed = parseLog(rawLog)
let validReadings = parsed.valid

print("--- 1.2 parseLog ---")
print("Valid readings: \(validReadings.count), corrupted: \(parsed.invalidCount)")
print(parseLog(["O2:1", "bad", "TEMP:-3"]))

let A = parsed.invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let oxygenReadings = select(validReadings) { $0.sensor == "O2" }
let pressureReadings = select(validReadings) { $0.sensor == "PRESS" }

print("--- 2.1 select ---")
print("O2 values:", values(of: oxygenReadings))
print("PRESS values:", values(of: pressureReadings))

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }
    return (min: minValue, max: maxValue, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print("--- 2.2 stats ---")
print(stats(3, 8, 1) as Any)
print(stats() as Any)
print(stats(of: values(of: oxygenReadings)) as Any)

let B = Int(stats(of: values(of: oxygenReadings))?.average ?? 0)

// 2.3 · The Closure Ladder
let sort1 = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let sort2 = validReadings.sorted(by: { a, b in return a.value > b.value })
let sort3 = validReadings.sorted(by: { a, b in a.value > b.value })
let sort4 = validReadings.sorted(by: { $0.value > $1.value })
let sort5 = validReadings.sorted { $0.value > $1.value }

func sameOrder(_ first: [Reading], _ second: [Reading]) -> Bool {
    guard first.count == second.count else { return false }
    for index in 0..<first.count {
        if first[index].sensor != second[index].sensor || first[index].value != second[index].value {
            return false
        }
    }
    return true
}

print("--- 2.3 closure ladder ---")
print("Sorted:", values(of: sort1))
print("All five sorts match:",
      sameOrder(sort1, sort2) && sameOrder(sort1, sort3) && sameOrder(sort1, sort4) && sameOrder(sort1, sort5))


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

print("--- 3.1 chooseProtocol ---")
print(chooseProtocol(for: 10)(10))   // 15
print(chooseProtocol(for: 30)(30))   // 27
print(chooseProtocol(for: 20)(20))   // 20

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    let safeRange = 18...24
    var temp = start
    var steps = 0
    while !safeRange.contains(temp) && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (finalTemp: temp, steps: steps, isStable: safeRange.contains(temp))
}

print("--- 3.2 runUntilStable ---")
print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

let temperatureReadings = select(validReadings) { $0.sensor == "TEMP" }
let lowestTemp = stats(of: values(of: temperatureReadings))?.min ?? 0
print("Lowest valid temperature: \(lowestTemp)")

let C = runUntilStable(from: lowestTemp).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print("--- 4.1 oxygenLevel ---")
print(oxygenLevel(of: crew[0]) as Any)   // Timur
print(oxygenLevel(of: crew[1]) as Any)   // Dana, no tank

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(member.module?.name ?? "open space"))"
    }
    return level < 20 ? "\(member.name): \(level)% CRITICAL" : "\(member.name): \(level)% OK"
}

print("--- 4.2 status ---")
for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    let capacity = 100
    guard amount > 0 else { return 0 }
    let freeSpace = max(0, capacity - target)
    let actual = min(amount, source, freeSpace)
    source -= actual
    target += actual
    return actual
}

print("--- 4.3 transferOxygen ---")
var testSource = 50
var testTarget = 90
print("Moved \(transferOxygen(from: &testSource, to: &testTarget, amount: 30)), source \(testSource), target \(testTarget)")
print("Negative amount moved \(transferOxygen(from: &testSource, to: &testTarget, amount: -5))")

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Lab → Hab: moved \(moved). Lab \(labTank.level)%, Hab \(habTank.level)%")
} else {
    print("Transfer impossible: a module has no tank")
}

let D = hab.oxygenTank?.level ?? 0

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    found.sort { $0.priority < $1.priority }
    var result: [String] = []
    for member in found {
        result.append(member.name)
    }
    return result
}

print("--- 4.4 evacuationOrder ---")
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Timur", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/

// Problems found:
// 1. reportOxygen: `member.module!` crashes for Nurlan (module == nil, open space).
// 2. reportOxygen: `.oxygenTank!` crashes for Dana (Dock has no tank).
// 3. firstCritical: `oxygenLevel(of: member)!` crashes on the first member without data
//    (Dana is second in the array, so the loop never even reaches Aigerim).
// 4. firstCritical (logic bug): the loop never stops, `result` is overwritten every time,
//    so it returns the LAST critical member, not the first one. With the starter data only
//    one member is critical, so the bug is invisible.
// 5. firstCritical: `return result!` crashes when nobody is critical
//    (after the Lab → Hab transfer nobody is below 20).
// 6. The return type String cannot express "nobody is critical" — it must be String?.

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else { continue }
        if level < 20 {
            return member.name
        }
    }
    return nil
}

print("--- Level 5 · fixed saboteur code ---")
for member in crew {
    print(reportOxygen(for: member))
}
print("First critical in real crew:", firstCritical(in: crew) ?? "nobody")

// Test for the logic bug: two critical members, the FIRST one must be returned.
let testModuleA = Module(name: "TestA", oxygenTank: Tank(level: 5))
let testModuleB = Module(name: "TestB", oxygenTank: Tank(level: 10))
let testCrew = [
    CrewMember(name: "Ghost", role: "Test", priority: 9, module: nil),
    CrewMember(name: "First", role: "Test", priority: 1, module: testModuleA),
    CrewMember(name: "Second", role: "Test", priority: 2, module: testModuleB)
]
let criticalResult = firstCritical(in: testCrew) ?? "nobody"
print("Test firstCritical returns 'First':", criticalResult == "First" ? "PASSED" : "FAILED (\(criticalResult))")
print("Test empty crew returns nil:", firstCritical(in: []) == nil ? "PASSED" : "FAILED")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var firedCount = 0
    return { level in
        guard level < threshold else { return false }
        firedCount += 1
        print("Alarm #\(firedCount)")
        return true
    }
}

print("--- Bonus · makeAlarm ---")
let alarm = makeAlarm(threshold: 20)
print(alarm(12))   // Alarm #1 → true
print(alarm(40))   // false
print(alarm(5))    // Alarm #2 → true


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    guard let makes the unwrapped value available for the REST of the function, and its
    else branch must leave the scope (return / continue / break). if let keeps the value
    only inside its braces. With guard the "happy path" stays at the left margin.
    In parseReading, if let would turn into a pyramid:
        if let parts = splitOnce(raw, by: ":") {
            if !parts.0.isEmpty {
                if let value = Int(parts.1) { ... return reading }
            }
        }
        return nil
    Three levels of nesting for one simple check.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    A variadic parameter is [Int] only INSIDE the function. At the call site it expects
    separate Int arguments separated by commas, and Swift has no "splat" operator to unpack
    an array into them. That is why stats(of:) takes [Int] and the variadic version just
    calls it.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    Swift's exclusive access rule: two inout parameters cannot access the same variable at
    the same time ("overlapping accesses to 'x'"). Otherwise source -= actual and
    target += actual would both write to x, and the oxygen would appear/disappear
    depending on the order of writes.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    ?? needs the same type on both sides: Int? ?? Int gives Int. "no data" is a String,
    so the types don't match. Fix: oxygenLevel(of: dana).map(String.init) ?? "no data",
    or simply if let / guard let and build the string by hand (like status(of:)).

 5. Full type of chooseProtocol:
    (Int) -> (Int) -> Int
    Read it from the left: "a function that takes an Int (the temperature) and returns a
    function that takes an Int and returns an Int". The arrow is right-associative, so it
    means (Int) -> ((Int) -> Int).

 Bonus. Where does the alarm counter live after makeAlarm returns?
    firedCount is captured by the closure. Swift moves it from the stack into a heap box
    that the closure holds a reference to, so it lives as long as the closure (alarm)
    lives. Each call of makeAlarm creates a new, independent counter.
*/
