// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Author: Zhanassyl Rysbek


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> One battery is physically shared by whoever
// holds it (the drone, the charging dock), so every holder must see the same charge —
// that needs reference semantics.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(100, charge + amount)
    }
}

print("--- Level 1 · PowerCell ---")
let cell = PowerCell(charge: 140)
print("init(140) → \(cell.level())")
print("spend(30): \(cell.spend(30)) → \(cell.level())")
print("spend(500): \(cell.spend(500)) → \(cell.level())")
print("spend(-5): \(cell.spend(-5)) → \(cell.level())")
cell.recharge(by: 50)
print("recharge(50) → \(cell.level())")
cell.recharge(by: -10)
print("recharge(-10) → \(cell.level())")
print("PowerCell(charge: -20) → \(PowerCell(charge: -20).level())")

// Encapsulation proof (leave this commented, with the compiler error):
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> No subclass can replace the shift
// ritual, so "pay powerCost first, work only if paid" is guaranteed for every drone,
// present and future.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a hull seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

print("--- Level 2 · Fleet ---")
var fleetBuilder: [Drone] = []
for record in fleetData {
    guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
        print("Warning: unknown drone kind '\(record.kind)' for \(record.id), skipped")
        continue
    }
    fleetBuilder.append(drone)
}
let fleet: [Drone] = fleetBuilder
for drone in fleet {
    print(drone.statusLine)
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

print("--- Level 3 · Shift ---")
let A = runShift(fleet, rounds: 3)

var remainingCharge = 0
var readyDrones = 0
for drone in fleet {
    print(drone.statusLine)
    remainingCharge += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        readyDrones += 1
    }
}
print("Work units: \(A), remaining charge: \(remainingCharge), ready for one more task: \(readyDrones)")

// Second test: a drone with an empty battery produces nothing and does not go negative.
let deadWelder = WelderDrone(id: "W-0", cell: PowerCell(charge: 0))
print("Dead welder shift work: \(runShift([deadWelder], rounds: 2)), charge \(deadWelder.cell.level())")

let B = remainingCharge
let C = readyDrones


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  -> Drone is a class: the
// method changes the object behind the reference, never the reference `self` itself,
// so there is nothing for `mutating` to allow.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(100, chargeLevel + amount)
    }
}

var sensorBuilder: [SensorModule] = []
for record in sensorData {
    sensorBuilder.append(SensorModule(id: record.id, chargeLevel: record.charge))
}
let sensors: [SensorModule] = sensorBuilder

print("--- Level 4 · Rechargeable ---")
var testSensor = SensorModule(id: "test", chargeLevel: 90)
testSensor.recharge(by: 30)
print("Sensor recharge(30) from 90 → \(testSensor.chargeLevel)")
let testScanner = ScannerDrone(id: "S-T", cell: PowerCell(charge: 10))
testScanner.recharge(by: 25)
print("Drone recharge(25) from 10 → \(testScanner.cell.level())")

// 4.3
// Why could [Drone] never have held the sensors?  -> SensorModule is a struct and not a
// subclass of Drone, so it is not a Drone; [Diagnosable] accepts anything that conforms.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "=== DIAGNOSTICS (\(components.count) components) ===\n"
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }

print("--- Level 4 · Diagnostics report ---")
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    /// The Health Rule — the only place in the file where the thresholds exist.
    func healthCode(for charge: Int) -> Int {
        switch charge {
        case ..<20:  return 2   // critical
        case 20..<50: return 1  // warning
        default:     return 0   // nominal
        }
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(for: signalStrength) }

    func diagnose() -> String {
        "⚠️ LEGACY HARDWARE ⚠️ \(name) — signal \(signalStrength), code \(statusCode). Schedule manual inspection."
    }
}

components.append(beacon)

print("--- Level 5 · Report with the beacon ---")
print(diagnosticsReport(components))

var statusSum = 0
for component in components {
    statusSum += component.statusCode
}
let D = statusSum

// 5.3
extension Int {
    var powerBar: String {
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }
}

print("--- Level 5.3 · powerBar ---")
print("42  → \(42.powerBar)")
print("-5  → \((-5).powerBar)")
print("250 → \(250.powerBar)")


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

print("--- Level 6 · fixes ---")

// Report 1
// Expected: PatchDrone produces 30 work units per task.
// Actual: does not compile — "overriding declaration requires an 'override' keyword".
// Rule: in Swift, replacing a superclass method must be marked `override` explicitly,
// so you can never override something by accident (or think you did when you didn't).
// Fix:
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}
let patch = PatchDrone(id: "P-1", cell: PowerCell(charge: 50))
print("Report 1 fixed: PatchDrone runOnce → \(patch.runOnce())")

// Report 2
// Expected: a HeavyWelder that always produces 999 units, ignoring the battery.
// Actual: does not compile, twice — WelderDrone is `final` ("inheritance from a final
// class 'WelderDrone'"), and runOnce() is `final` ("instance method overrides a 'final'
// instance method"). Rule: `final` forbids subclassing / overriding. That is exactly the
// protection we wanted: nobody may skip paying for the work.
// Fix: subclass Drone and change only what is allowed — the cost and the work.
final class HeavyWelder: Drone {
    override var powerCost: Int { 50 }
    override func performTask() -> Int { 90 }
}
let heavy = HeavyWelder(id: "HW-1", cell: PowerCell(charge: 60))
print("Report 2 fixed: HeavyWelder runOnce → \(heavy.runOnce()), then \(heavy.runOnce())")

// Report 3
// Expected: print "W-9 welded a hull seam".
// Actual: does not compile — "value of type 'Drone' has no member 'weldSeam'". The
// static type of `first` is Drone; the compiler only allows what Drone declares, even
// though the object at runtime is a WelderDrone.
// Fix: ask at runtime with a conditional cast.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let firstReportDrone = reportFleet[0]
if let welder = firstReportDrone as? WelderDrone {
    print("Report 3 fixed:", welder.weldSeam())
} else {
    print("Report 3: not a welder")
}
// as? returns an optional because the cast can fail — the element might be a scanner or
// a cargo drone, and then there is no WelderDrone to give back, only nil.

// Report 4
// Expected: "thruster T-1". Actual: compiles and prints "generic component".
// Rule: label() is NOT a requirement of the protocol, it only exists in the extension.
// Such methods are dispatched statically, by the type the compiler sees — here
// `Labelled`, so the extension version runs. Only requirements go through the protocol's
// witness table (dynamic dispatch) and reach the struct's own implementation.
// Fix (one line): declare label() as a requirement.
protocol Labelled {
    var componentID: String { get }
    func label() -> String          // ← the one line that changes the output
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4 fixed:", parts[0].label())


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// 1. Forbidding direct use of Drone:
//    • Runtime: make the base method trap —
//          func performTask() -> Int { fatalError("Drone is abstract: override performTask()") }
//      Drone(id:cell:) still compiles, but the first runOnce() on a bare Drone crashes.
//    • Compile time: make the base type a protocol (below). A protocol cannot be
//      instantiated at all, and a conforming type that forgets performTask() does not
//      compile. (Another compile-time trick: `fileprivate init` on Drone with subclasses
//      in the same file — code in other files cannot create a bare Drone.)
//
// 2. Protocol-based redesign: the shared ritual lives in a protocol extension,
//    WelderUnit is a struct.

protocol RepairUnit {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension RepairUnit {
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

struct WelderUnit: RepairUnit {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

struct CargoUnit: RepairUnit {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 20 }
    func performTask() -> Int { 25 }
}

let units: [RepairUnit] = [
    WelderUnit(id: "WU-1", cell: PowerCell(charge: 80)),
    CargoUnit(id: "CU-1", cell: PowerCell(charge: 30))
]
var unitWork = 0
for unit in units {
    unitWork += unit.runOnce()
}
print("Bonus · protocol fleet work: \(unitWork)")

// 3. Comparison: the class design gives one real base type, `final` on the ritual and
//    `super`, but a bare Drone can still be created. The protocol design cannot be
//    instantiated and lets structs and classes join, but a protocol extension method can
//    be "shadowed" (Report 4) instead of being truly final. For this station I'd keep the
//    class: drones are long-lived machines with identity, and if they had to share
//    mutable state (one dock battery, a shared work log) reference semantics are exactly
//    what we need — with struct drones every copy would get its own state.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the keyword,
    while a struct must write it?
    `mutating` means "this method may change self". For a struct self IS the value, so
    changing a property changes self and needs permission. For a class self is a reference;
    changing a property changes the object, the reference stays the same — so a class
    method is always allowed to do it and the keyword is not used.

 2. One thing inheritance does that protocols cannot, and one thing protocols do that
    inheritance cannot:
    Inheritance shares STORED state and implementation (id, cell, init) and allows
    `super` and `final` overriding control. Protocols unite unrelated types — classes,
    structs, enums, even types you can't edit (LegacyBeacon via extension) — and a type
    can conform to many protocols but inherit from only one class.

 3. What does `final` prevent, and what did it protect in runOnce()?
    On a class it prevents subclassing; on a method/property it prevents overriding.
    final runOnce() guarantees every drone pays powerCost before working — no subclass
    (like HeavyWelder in Report 2) can return work for free or skip the battery check.

 4. In Report 4, why did the protocol extension's method win?
    label() was not a protocol requirement, so the call was resolved statically using the
    compile-time type of parts[0], which is `Labelled`. The compiler only knows the
    extension's label(). Making label() a requirement puts it into the witness table and
    the call is dispatched dynamically to Thruster's own version.
*/
