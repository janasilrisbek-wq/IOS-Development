// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Author: Zhanassyl Rysbek


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("--- 1.1 Deck ---")
for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let steps = min(max(mass / 500, 0), AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: steps) ?? .red
    }
}

print("--- 1.2 AlarmLevel ---")
print(AlarmLevel.level(forTotalMass: 0))      // green
print(AlarmLevel.level(forTotalMass: 940))    // yellow
print(AlarmLevel.level(forTotalMass: 4000))   // red


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    switch parts[0] {
    case "crate":
        guard parts.count == 3, let id = Int(parts[1]), let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: mass)
    case "container":
        guard parts.count == 3, !parts[1].isEmpty, let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: mass)
    case "livestock":
        guard parts.count == 4, let count = Int(parts[2]), let perUnit = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
    default:
        return .unknown(raw: line)
    }
}

print("--- 2.2 parseEntry ---")
print(parseEntry("crate:101:120"))
print(parseEntry("livestock:lab mice:12:2"))
print(parseEntry("crate:104:abc"))

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):
        return massKg
    case let .container(_, massKg):
        return massKg
    case let .livestock(_, count, massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var manifestTotal = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    manifestTotal += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
}

print("--- 2.3 mass ---")
print("Total manifest mass: \(manifestTotal) kg, unknown lines: \(unknownCount)")
print("Mass of one container:", mass(of: parseEntry("container:KZ-ALM-7:340")))

let A = manifestTotal


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

print("--- 3.1 CrewSnapshot ---")
var rookie = CrewSnapshot.rookie(named: "Aruzhan")
print("Rookie:", rookie)
rookie.breathe(130)
rookie.move(to: .engine)
print("After breathe(130) + move(.engine):", rookie)
rookie.reviveInMedbay()
print("After reviveInMedbay():", rookie)

// 3.2
var rosterBuilder: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("Warning: \(record.name) is on unknown deck '\(record.deck)', skipped")
        continue
    }
    rosterBuilder.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}
let crewRoster: [CrewSnapshot] = rosterBuilder

print("--- 3.2 crewRoster ---")
for member in crewRoster {
    print("\(member.name) on \(member.deck.rawValue), O2 \(member.oxygen)")
}

// 3.3 · Value-semantics demonstration
print("--- 3.3 value semantics ---")

// 1) copy
let original = crewRoster[0]
var copy = original
print("1) before: original \(original.oxygen), copy \(copy.oxygen)")
copy.breathe(50)
print("1) after copy.breathe(50): original \(original.oxygen), copy \(copy.oxygen)")

// 2) plain parameter
func drainOxygen(_ snapshot: CrewSnapshot) -> CrewSnapshot {
    var local = snapshot          // parameters are let; the function works on its own copy
    local.breathe(40)
    return local
}
let dana = crewRoster[1]
print("2) before: dana \(dana.oxygen)")
let drained = drainOxygen(dana)
print("2) after drainOxygen(dana): dana \(dana.oxygen), returned copy \(drained.oxygen)")

// 3) inout
func drainOxygenInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(40)
}
var aigerim = crewRoster[2]
print("3) before: aigerim \(aigerim.oxygen)")
drainOxygenInPlace(&aigerim)
print("3) after drainOxygenInPlace(&aigerim): aigerim \(aigerim.oxygen)")


// MARK: Level 4 · The Teleport Pod

// 4.1
// The struct got a memberwise initializer for free; a class never gets one, because classes
// support inheritance and Swift cannot guess how a subclass should initialise its parent.
// Here `occupant` would be optional anyway, but `id` and `chargeLevel` have no default,
// so the class must have an explicit init.
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    // Bonus
    deinit {
        print("deinit: pod \(id) destroyed")
    }
}

// 4.2 · Charge ledger
print("--- 4.2 charge ledger ---")
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)
print("Start: \(ledgerPod.chargeLevel)")

for name in ["Timur", "Dana", "Nurlan"] {
    var member: CrewSnapshot?
    for snapshot in crewRoster where snapshot.name == name {
        member = snapshot
    }
    guard let passenger = member else {
        print("\(name) not in roster")
        continue
    }
    let loaded = ledgerPod.load(passenger)
    let arrived = ledgerPod.fire()?.name ?? "nobody"
    print("load \(name): \(loaded), fire → \(arrived). Charge: \(ledgerPod.chargeLevel)")
}
let emptyShot = ledgerPod.fire()
print("fire empty pod → \(emptyShot?.name ?? "nil"). Charge: \(ledgerPod.chargeLevel)")

let C = ledgerPod.chargeLevel

// 4.3 · Reference-semantics demonstration
print("--- 4.3 reference semantics ---")
let podOne = TeleportPod(id: "R-1", chargeLevel: 70)
let podTwo = podOne
print("before: podOne \(podOne.chargeLevel), podTwo \(podTwo.chargeLevel)")
podTwo.chargeLevel = 5
print("after podTwo.chargeLevel = 5: podOne \(podOne.chargeLevel), podTwo \(podTwo.chargeLevel)")

let snapOne = CrewSnapshot.rookie(named: "Dias")
var snapTwo = snapOne
print("before: snapOne \(snapOne.oxygen), snapTwo \(snapTwo.oxygen)")
snapTwo.oxygen = 5
print("after snapTwo.oxygen = 5: snapOne \(snapOne.oxygen), snapTwo \(snapTwo.oxygen)")
// Rule: assigning a class copies the reference (both names see one object),
// assigning a struct copies the value (two independent objects).


// MARK: Level 5 · Station Systems

// 5.1
// Station is a class: there is exactly one live station that many parts of the program
// must share and see the same state of.
final class Station {
    // Stored let
    let callSign: String

    // Stored var with observers
    var hullIntegrity: Int {
        willSet {
            print("Hull integrity: \(hullIntegrity) → \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    // Stored var
    var oxygenByDeck: [Deck: Int]

    // Lazy stored
    lazy var fullDiagnostics: String = self.buildDiagnostics()

    // Computed, read-only (no `get` keyword)
    var totalOxygen: Int {
        var total = 0
        for (_, oxygen) in oxygenByDeck {
            total += oxygen
        }
        return total
    }

    // Computed, get + set (default newValue)
    var averageOxygen: Int {
        get {
            guard !oxygenByDeck.isEmpty else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Array(oxygenByDeck.keys) {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = 100
        var table: [Deck: Int] = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("Station: skipped reading for unknown deck '\(reading.deck)'")
                continue
            }
            table[deck] = reading.oxygen
        }
        self.oxygenByDeck = table
    }

    private func buildDiagnostics() -> String {
        print("Running full scan...")
        var report = "\(callSign) diagnostics:"
        for deck in Deck.allCases {
            report += " \(deck.rawValue)=\(oxygenByDeck[deck] ?? 0)"
        }
        report += " | hull \(hullIntegrity)%"
        return report
    }
}

print("--- 5.1 Station ---")
let station = Station(callSign: "ALMA-7", readings: deckReadings)
let B = station.averageOxygen
print("callSign: \(station.callSign), total O2: \(station.totalOxygen), average O2: \(B)")

print("Before touching fullDiagnostics (no scan message above this line).")
print("First access:", station.fullDiagnostics)
print("Second access:", station.fullDiagnostics)   // no "Running full scan..." this time

let quietStation = Station(callSign: "ALMA-8", readings: deckReadings)
print("\(quietStation.callSign) created, fullDiagnostics never touched → no scan printed")

station.averageOxygen = 50
print("After averageOxygen = 50: total \(station.totalOxygen), average \(station.averageOxygen)")

// 5.2 · The clamp trap
print("--- 5.2 clamp trap ---")
station.hullIntegrity = 130
print("hullIntegrity:", station.hullIntegrity)   // 100
station.hullIntegrity = -40
print("hullIntegrity:", station.hullIntegrity)   // 0
station.hullIntegrity = 55
print("hullIntegrity:", station.hullIntegrity)   // 55
// Assigning to a property inside its own didSet does NOT call willSet/didSet again —
// Swift writes the value directly into storage, so the clamp cannot loop forever.


// MARK: Level 6 · Incident Reports

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

// Report 1 — compiles, wrong.
// Expected: every crew member loses 10 oxygen.
// Actual: roster[0].oxygen is unchanged (62). `for var member` gives a COPY of each struct;
// the copy is changed and thrown away. Rule: structs are value types.
// Fix: change the elements through their index.
print("--- Level 6 fixes ---")
var fixedRoster = crewRoster
for index in fixedRoster.indices {
    fixedRoster[index].oxygen -= 10
}
print("Report 1 fixed:", fixedRoster[0].oxygen)   // 52

// Report 2 — compiles, wrong.
// Expected: podA keeps 100. Actual: prints 0. `let podB = podA` copies the reference,
// both names point to one object. Rule: classes are reference types.
// Fix: create a separate pod (an explicit copy).
let fixedPodA = TeleportPod(id: "A", chargeLevel: 100)
let fixedPodB = TeleportPod(id: "A-copy", chargeLevel: fixedPodA.chargeLevel)
fixedPodB.chargeLevel = 0
print("Report 2 fixed:", fixedPodA.chargeLevel)   // 100

// Report 3 — does NOT compile.
// error: cannot use mutating member on immutable value: 'self' is immutable
// Rule: methods of a struct cannot change its stored properties unless they are `mutating`.
// Fix:
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = Logbook()
logbook.add("Day 10: teleporter fixed")
print("Report 3 fixed:", logbook.entries)

// Report 4 — the first assignment does NOT compile, the second one is fine.
// snapshot.oxygen = 40 → error: cannot assign to property: 'snapshot' is a 'let' constant
// `let` on a struct freezes the whole VALUE, including every property inside it.
// `let` on a class freezes only the REFERENCE (you can't point `pod` at another pod),
// the object it points to is still mutable, so pod.chargeLevel = 10 is legal.
// Fix: declare the snapshot with var.
var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
fixedSnapshot.oxygen = 40
let fixedPod = TeleportPod(id: "B", chargeLevel: 50)
fixedPod.chargeLevel = 10
print("Report 4 fixed:", fixedSnapshot.oxygen, fixedPod.chargeLevel)


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }

final class FlightRecorder {
    // private: blocks any code outside this type from reading, replacing or clearing the list
    private var entries: [String] = []

    // private(set): blocks writes from outside, so nobody can set isSealed back to false
    private(set) var isSealed = false

    // internal: reading the count from outside is allowed, it changes nothing
    internal var entryCount: Int {
        entries.count
    }

    // internal: anyone may read the formatted transcript (a copy, not the array itself)
    internal var transcript: String {
        var text = ""
        for (index, entry) in entries.enumerated() {
            text += "\(index + 1). \(entry)\n"
        }
        return text
    }

    // internal: the only way in — refuses entries after sealing
    @discardableResult
    internal func add(_ entry: String) -> Bool {
        guard !isSealed else { return false }
        entries.append(entry)
        return true
    }

    // internal: sealing is one-way, there is no unseal method
    internal func seal() {
        isSealed = true
    }

    // fileprivate: hidden from other files, but the audit function below (same file) may use it
    fileprivate func lastEntry() -> String? {
        entries.last
    }
}

// A free function elsewhere in the file that uses the fileprivate helper:
func auditTranscript(of recorder: FlightRecorder) -> String {
    let last = recorder.lastEntry() ?? "no entries"
    return "AUDIT: \(recorder.entryCount) entries, sealed: \(recorder.isSealed), last: \(last)"
}

print("--- Level 7 FlightRecorder ---")
let recorder = FlightRecorder()
recorder.add("03:14 meteorite impact")
recorder.add("Day 10 teleporter incident")
print(recorder.transcript, terminator: "")
recorder.seal()
print("Add after seal accepted:", recorder.add("rewrite history"))
print(auditTranscript(of: recorder))

// Attempts to break it from outside (do not compile):
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

print("--- Bonus · deinit and === ---")
var keptPod: TeleportPod?
do {
    let temporaryPod = TeleportPod(id: "TMP", chargeLevel: 30)
    keptPod = temporaryPod
    print("Inside do-block: two references (temporaryPod + keptPod)")
}
print("Left the do-block: temporaryPod is gone, keptPod still holds the pod → no deinit yet")
keptPod = nil   // ← deinit fires on THIS line: the last strong reference is removed
print("After keptPod = nil")
// ARC counts strong references. Leaving the block removed one of two, so the count was 1.
// Setting keptPod to nil dropped it to 0 and the pod was destroyed immediately.
// (In an Xcode Playground the timing can be delayed, because the playground itself keeps
// values for the results sidebar. Run with `swift file.swift` to see the exact line.)

func comparePods(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "same pod (one object, two references)"
    }
    if first.id == second.id && first.chargeLevel == second.chargeLevel {
        return "two different pods with equal contents"
    }
    return "two different pods"
}

let record1 = TeleportPod(id: "D-1", chargeLevel: 60)
let record2 = record1
let record3 = TeleportPod(id: "D-1", chargeLevel: 60)
print(comparePods(record1, record2))
print(comparePods(record1, record3))
// === compares identity (the address of an object). A struct has no identity: every
// assignment makes an independent copy, so `===` is not defined for CrewSnapshot at all.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    Structs automatically get a memberwise init(name:deck:oxygen:). Classes never do,
    because of inheritance: Swift can't know how subclasses should initialise the parent,
    so any class with properties without defaults must write init itself.

 2. What does `mutating` do to self, and why do classes never need it?
    In a struct method self is a constant. `mutating` makes self an inout parameter, so
    the method may change properties or replace self entirely (reviveInMedbay). A class
    method works through a reference — the object is always mutable, self is the pointer.

 3. In Report 4 both values are `let`. What exactly does `let` freeze?
    Struct: the whole value — no property can change. Class: only the reference — you
    cannot point the constant at another object, but the object's var properties can
    still be changed.

 4. Why must a lazy property be var? When does lazy change behaviour?
    Its value is written after initialisation (on first access), and a let must be set
    during init. Behaviour change: fullDiagnostics captures the hull/oxygen values at
    the moment of FIRST access, not at init. Access it after averageOxygen = 50 and the
    report says 50; access it earlier and it shows the old values forever. Side effects
    (the "Running full scan..." print) also only happen if someone touches it.

 5. private vs fileprivate in FlightRecorder:
    auditTranscript(of:) is a free function outside the class. If lastEntry() were
    private, the audit function couldn't call it. fileprivate lets this file's audit
    code use it, while code in other files still can't.

 Bonus. deinit fires on `keptPod = nil` (see above). === can't be used on CrewSnapshot
 because structs are values without identity — only class instances (AnyObject) can be
 compared by identity.
*/
