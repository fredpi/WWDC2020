
import Foundation
import Helpers

public struct Simulation {
    // MARK: - Properties
    public let configuration: Configuration
    private var points: [Point]

    // MARK: - Initializers
    public init(config: Configuration) {
        self.configuration = config
        self.points = []
    }

    // MARK: - Methods
    public mutating func simulate(timeProgress: Double) -> [Point] {
        // Set upper limit for timeProgress to 0.05 (20 Hertz)
        let timeProgress = min(0.05, timeProgress)

        if points.isEmpty {
            // Generate points if none are there
            points = generateInitialPoints()
        } else {
            // Simulate existing points
            var nextStepPoints = points.map { (point: Point) -> Point in
                var point = point

                // Manage state transitions
                switch point.state {
                case let .exposed(timeSinceExposal, future), let .infectious(timeSinceExposal, future), let .immune(timeSinceExposal, future):
                    let newTime = timeSinceExposal + timeProgress
                    let futureApplied = applyIfNeeded(future: future, to: &point, at: newTime)
                    if !futureApplied {
                        point.state = point.state.bumpedStateTime(by: timeProgress)
                    }

                case .dead:
                    point.state = point.state.bumpedStateTime(by: timeProgress)

                case .susceptible:
                    break
                }

                // Simulate movement
                point.center += timeProgress * point.actualVelocity

                return point
            }

            // Take snapshot & rasterize after performing the simulation already
            let rasterizer = Rasterizer(points: nextStepPoints.filter { $0.isVisible }, rasterCount: 20)

            // Handle point-to-point collisions
            for (index, point) in nextStepPoints.enumerated() {
                var point = point

                let collidedNeighbors = rasterizer.getNeighbors(for: point).filter { point.hasCollided(with: $0) }
                if !collidedNeighbors.isEmpty {
                    // Determine first collided neighbor
                    var minimumT: Double!
                    var firstCollidedNeighbor: Point!

                    for neighbor in collidedNeighbors {
                        // Calculate collision point
                        let point1 = point.center - timeProgress * point.actualVelocity
                        let point2 = point.center
                        let neighbor1 = neighbor.center - timeProgress * neighbor.actualVelocity
                        let neighbor2 = neighbor.center
                        let a = point1 - neighbor1
                        let b = point2 - point1 - (neighbor2 - neighbor1)
                        let aLengthSquared = pow(a.x, 2) + pow(a.y, 2)
                        let bLengthSquared = pow(b.x, 2) + pow(b.y, 2)

                        let p = 2 * a * b / bLengthSquared
                        let q = (aLengthSquared - 4 * configuration.fixed.squaredPointRadius) / bLengthSquared

                        var t = -p/2 - sqrt(pow(p, 2)/4 - q)

                        // When velocities are quite similar, b_x and b_y are small, so squaring them and then dividing by them is error-prone, leading to an incorrect (huge) t
                        // Therefore, if t is out of bounds, we just set it to 0, meaning the point center gets reset to the last value
                        // Also if two non-moving points collide (e. g. because this algorithm only calculates the first collision each step),
                        // t is NaN or infinite and that shouldn't be the case
                        if t > 1 || t < 0 || t.isNaN || t.isInfinite {
                            t = 0
                        }

                        if minimumT == nil || t < minimumT {
                            minimumT = t
                            firstCollidedNeighbor = neighbor
                        }
                    }

                    // Manage collisions for moving points
                    if !point.actualVelocity.isZero {
                        let pointAtCollision = point.center - (1 - minimumT) * timeProgress * point.actualVelocity

                        // Set point to collision place (will not affect the value within the rasterizer)
                        point.center = pointAtCollision

                        // Set velocity
                        let neighborAtCollision = firstCollidedNeighbor.center - (1 - minimumT) * timeProgress * firstCollidedNeighbor.actualVelocity
                        let connectingVector = neighborAtCollision - pointAtCollision
                        let newVelocityY = configuration.fixed.velocityAbs / sqrt(pow(connectingVector.x / connectingVector.y, 2) + 1) * -connectingVector.y.sign
                        let newVelocityX = sqrt(configuration.fixed.squaredVelocityAbs - pow(newVelocityY, 2)) * -connectingVector.x.sign

                        if newVelocityX.isFinite && newVelocityY.isFinite {
                            point.nominalVelocity = Vector(x: newVelocityX, y: newVelocityY)
                        }
                    }

                    // Manage infections
                    if !point.isFullyProtected, !firstCollidedNeighbor.isFullyProtected, point.state == .susceptible, case .infectious = firstCollidedNeighbor.state {
                        let future = generateFutureForExposed()
                        point.state = .exposed(timeSinceExposal: 0, future: future)
                        applyIfNeeded(future: future, to: &point, at: 0)
                    }
                }

                nextStepPoints[index] = point
            }

            // Handle point-to-wall collisions
            for (index, point) in nextStepPoints.enumerated() {
                let pointRadius = configuration.fixed.pointRadius
                let offset = Vector(
                    x: point.center.x - pointRadius < 0 ? point.center.x - pointRadius : point.center.x + pointRadius > 1 ? point.center.x + pointRadius - 1 : 0,
                    y: point.center.y - pointRadius < 0 ? point.center.y - pointRadius : point.center.y + pointRadius > 0.5 ? point.center.y + pointRadius - 0.5 : 0
                )

                if offset != .zero {
                    var point = point

                    // These position & velocity adjustments are not exactly precise but work out properly
                    point.center -= offset
                    point.nominalVelocity.x *= offset.x == 0 ? 1 : -1
                    point.nominalVelocity.y *= offset.y == 0 ? 1 : -1

                    nextStepPoints[index] = point
                }
            }

            points = nextStepPoints
        }

        return points
    }

    // MARK: Initial Values
    private func generateInitialPoints() -> [Point] {
        guard configuration.behavior.numberOfPoints >= 1 else { return [] }

        // Generate all centers
        var points = [Point]()
        let centers = generateCenters(for: configuration.behavior.numberOfPoints)

        // Add first point that moves and isn't protected except for exact 0 / 1 values
        let firstPointIsMoving = configuration.behavior.movingShare != 0
        let firstPointIsFullyProtected = firstPointIsMoving ? configuration.behavior.protectionShareAmongMoving == 1 : configuration.behavior.protectionShareAmongResting == 1
        points.append(
            Point(
                configuration: configuration,
                center: centers.first!,
                nominalVelocity: firstPointIsMoving ? generateVelocity() : .zero,
                isFullyProtected: firstPointIsFullyProtected,
                state: .infectious(timeSinceExposal: 0, future: generateFutureForInfectious(timeSinceExposal: 0))
            )
        )

        guard configuration.behavior.numberOfPoints >= 2 else { return points }

        // Determine configurations of other points
        var movingPointsCount = Int(round(configuration.behavior.movingShare * Double(configuration.behavior.numberOfPoints)))
        var restingPointsCount = configuration.behavior.numberOfPoints - movingPointsCount
        var protectedAmongMovingCount = Int(round(configuration.behavior.protectionShareAmongMoving * Double(movingPointsCount)))
        var protectedAmongRestingCount = Int(round(configuration.behavior.protectionShareAmongResting * Double(restingPointsCount)))
        var unprotectedAmongMovingCount = movingPointsCount - protectedAmongMovingCount
        var unprotectedAmongRestingCount = restingPointsCount - protectedAmongRestingCount

        // Subtract configuration of first point
        if firstPointIsMoving && movingPointsCount > 0 {
            movingPointsCount -= 1

            if firstPointIsFullyProtected && protectedAmongMovingCount > 0 {
                protectedAmongMovingCount -= 1
            } else {
                unprotectedAmongMovingCount -= 1
            }
        } else {
            restingPointsCount -= 1

            if firstPointIsFullyProtected && protectedAmongRestingCount > 0 {
                protectedAmongRestingCount -= 1
            } else {
                unprotectedAmongRestingCount -= 1
            }
        }

        // Create points using calculated configuration counts
        let counts = [protectedAmongMovingCount, unprotectedAmongMovingCount, protectedAmongRestingCount, unprotectedAmongRestingCount]
        for (index, count) in counts.enumerated() {
            let isMoving = index <= 1
            let isFullyProtected = index == 0 || index == 2
            let begin = counts[0..<index].reduce(0) { $0 + $1 } + 1 // + 1 because start point has already been added

            for i in begin..<(begin + count) {
                points.append(
                    Point(
                        configuration: configuration,
                        center: centers[i],
                        nominalVelocity: isMoving ? generateVelocity() : .zero,
                        isFullyProtected: isFullyProtected,
                        state: .susceptible
                    )
                )
            }
        }

        return points
    }

    private func generateVelocity() -> Vector {
        let x = Double.random(in: -configuration.fixed.velocityAbs...configuration.fixed.velocityAbs)
        return Vector(
            x: x,
            y: sqrt(configuration.fixed.squaredVelocityAbs - pow(x, 2)) * Double(2 * Int.random(in: 0...1) - 1) // random sign
        )
    }

    private func generateCenters(for numberOfPersons: Int) -> [Vector] {
        var coordinates = [Vector]()

        // 20 ~= (2 + 2,5)^2 => Distance of 2.5 * radius
        let aimedDistanceSquare = 20 * configuration.fixed.squaredPointRadius
        let maxAttemptCountPerCoordinate = 10

        // Try even improving the distribution within the ranges to
        for range in generateCenterRanges(for: numberOfPersons) {
            var bestAttempt: (coordinate: Vector, minDistanceSquare: Double)?

            for _ in 0..<maxAttemptCountPerCoordinate {
                let coordinate = Vector(x: Double.random(in: range.x), y: Double.random(in: range.y))

                let minDistanceSquare = coordinates.map { pow(coordinate.x - $0.x, 2) + pow(coordinate.y - $0.y, 2) }.min()
                if let minDistanceSquare = minDistanceSquare {
                    // Set bestAttempt if not set yet, replace it if this attempt is better
                    if bestAttempt == nil || minDistanceSquare > bestAttempt!.minDistanceSquare {
                        bestAttempt = (coordinate: coordinate, minDistanceSquare: minDistanceSquare)
                    }

                    // If this attempt fulfills the aimed distance, stop trying to get even better attempts
                    if minDistanceSquare >= aimedDistanceSquare { break }
                } else {
                    // This is the first coordinate (-> distance can't be calculated) -> just choose this attempt
                    bestAttempt = (coordinate: coordinate, minDistanceSquare: 0)
                    break
                }
            }

            coordinates.append(bestAttempt!.coordinate)
        }

        return coordinates
    }

    private func generateCenterRanges(for numberOfPersons: Int) -> [(x: Range<Double>, y: Range<Double>)] {
        // Calculate raster dimensions
        let yCountUnrounded = sqrt(Double(numberOfPersons) / 2)
        var xBoxCount = Int(2 * yCountUnrounded) // Int(double) floors the double
        var yBoxCount = Int(yCountUnrounded)

        if xBoxCount * yBoxCount < numberOfPersons {
            xBoxCount += 1 // Increase x first (doesn't change product so much)

            if xBoxCount * yBoxCount < numberOfPersons {
                // Increase y instead as a second attempt
                xBoxCount -= 1
                yBoxCount += 1
            }

            if xBoxCount * yBoxCount < numberOfPersons {
                // Increase both as solution
                xBoxCount += 1
            }
        }

        // Calculate spacings
        let minimumSideSpacing: Double = 3 // Measured in pointRadius
        let minimumCenterSideSpacing = minimumSideSpacing + 1
        let minimumCenterSideSpacingAbsolute = minimumCenterSideSpacing * configuration.fixed.pointRadius

        // This is just the minimum point spacing enforced by the raster
        // When the actual coordinates get generated, a greater distance may be achieved by trying & evaluating multiple random values within the range
        var minimumPointSpacing: Double = 1 // Measured in pointRadius

        var separatorLength: Double = 0
        var xBoxLength: Double = 0
        var yBoxLength: Double = 0

        while true {
            let centerSpacing = minimumPointSpacing + 2 // Add 2 * center to edge distance

            separatorLength = centerSpacing * configuration.fixed.pointRadius
            xBoxLength = (1 - (Double(xBoxCount - 1) * separatorLength) - 2 * minimumCenterSideSpacingAbsolute) / Double(xBoxCount)
            yBoxLength = (0.5 - (Double(yBoxCount - 1) * separatorLength) - 2 * minimumCenterSideSpacingAbsolute) / Double(yBoxCount)

            if xBoxLength > 0 && yBoxLength > 0 {
                // The spacing works out
                break
            } else if minimumPointSpacing > 1 {
                // Try to recover by reducing point spacing
                minimumPointSpacing -= 0.5
            } else {
                fatalError("Too many points to fit into the space!")
            }
        }

        // Calculate ranges
        var ranges = [(x: Range<Double>, y: Range<Double>)]()
        for x in 0..<xBoxCount {
            let xOrigin = minimumCenterSideSpacingAbsolute + Double(x) * (xBoxLength + separatorLength)
            let xTarget = xOrigin + xBoxLength
            for y in 0..<yBoxCount {
                let yOrigin = minimumCenterSideSpacingAbsolute + Double(y) * (yBoxLength + separatorLength)
                let yTarget = yOrigin + yBoxLength
                ranges.append((x: xOrigin..<xTarget, y: yOrigin..<yTarget))
            }
        }

        return ranges.shuffled().dropLast(xBoxCount * yBoxCount - numberOfPersons)
    }

    // MARK: Future Handling
    private func generateFutureForExposed() -> State.Future {
        let willTurnInfectious = Double.random(in: 0..<1) < configuration.illness.infectiousShare

        return State.Future(
            time: configuration.illness.incubationPeriod,
            state: willTurnInfectious
            ? .infectious(
                timeSinceExposal: configuration.illness.incubationPeriod,
                future: generateFutureForInfectious(timeSinceExposal: configuration.illness.incubationPeriod)
            )
            : .immune(
                timeSinceExposal: configuration.illness.incubationPeriod,
                future: generateFutureForImmune(timeSinceExposal: configuration.illness.incubationPeriod)
            )
        )
    }

    private func generateFutureForInfectious(timeSinceExposal: Double) -> State.Future {
        // As only infectious points will die in our simulation, we have to divide by the infectiousShare
        let willDie = Double.random(in: 0..<1) < configuration.illness.lethality / configuration.illness.infectiousShare

        return willDie
        ? State.Future(time: timeSinceExposal + configuration.illness.infectiousDuration, state: .dead(timeSinceDeath: 0))
        : State.Future(
            time: timeSinceExposal + configuration.illness.infectiousDuration,
            state: .immune(
                timeSinceExposal: timeSinceExposal + configuration.illness.infectiousDuration,
                future: generateFutureForImmune(timeSinceExposal: timeSinceExposal + configuration.illness.infectiousDuration)
            )
        )
    }

    private func generateFutureForImmune(timeSinceExposal: Double) -> State.Future? {
        let willKeepImmunity = Double.random(in: 0..<1) < configuration.immunity.permanentImmunityShare

        return willKeepImmunity
            ? nil
            : State.Future(time: timeSinceExposal + configuration.immunity.immunityDurationOfNonPermanentImmunes, state: .susceptible)
    }

    /// Returns true if future was applied
    @discardableResult
    private func applyIfNeeded(future: State.Future?, to point: inout Point, at time: Double) -> Bool {
        if let future = future, time >= future.time {
            point.state = future.state

            // Recursively apply future of future if needed
            switch point.state {
            case let .exposed(_, future), let .infectious(_, future), let .immune(_, future):
                applyIfNeeded(future: future, to: &point, at: time)

            case .dead, .susceptible:
                break
            }

            // Inform that future was applied
            return true
        }

        return false
    }
}
