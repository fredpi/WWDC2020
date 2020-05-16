
import Foundation

public struct Configuration {
    // MARK: - Subtypes
    public struct BehaviorConfiguration {
        public let numberOfPoints: Int
        public let movingShare: Double
        public let protectionShareAmongMoving: Double
        public let protectionShareAmongResting: Double
        public let infectiousSpeedReductionFactor: Double

        public init(
            numberOfPoints: Int,
            movingPercentage: Double,
            protectionPercentageAmongMoving: Double,
            protectionPercentageAmongResting: Double,
            infectiousSpeedReductionPercentage: Double
        ) {
            self.numberOfPoints = min(200, max(5, numberOfPoints)) // 5 - 200
            self.movingShare = min(1, max(0, movingPercentage / 100)) // 0 - 1
            self.protectionShareAmongMoving = min(1, max(0, protectionPercentageAmongMoving / 100)) // 0 - 1
            self.protectionShareAmongResting = min(1, max(0, protectionPercentageAmongResting / 100)) // 0 - 1
            self.infectiousSpeedReductionFactor = min(1, max(0, 1 - infectiousSpeedReductionPercentage / 100)) // 0 - 1
        }
    }

    public struct IllnessConfiguration {
        public let lethality: Double
        public let incubationPeriod: Double
        public let infectiousShare: Double
        public let infectiousDuration: Double

        public init(
            lethalityPercentage: Double,
            incubationPeriod: Double,
            infectiousPercentage: Double,
            infectiousDuration: Double
        ) {
            self.lethality = min(1, max(0, lethalityPercentage / 100)) // 0 - 1
            self.incubationPeriod = max(0, incubationPeriod) // 0 - ...
            self.infectiousShare = min(1, max(lethality, infectiousPercentage / 100)) // lethality - 1
            self.infectiousDuration = max(0, infectiousDuration) // 0 - ...
        }
    }

    public struct ImmunityConfiguration {
        public let permanentImmunityShare: Double
        public let immunityDurationOfNonPermanentImmunes: Double

        public init(
            permanentImmunityPercentage: Double,
            immunityDurationOfNonPermanentImmunes: Double
        ) {
            self.permanentImmunityShare = min(1, max(0, permanentImmunityPercentage / 100)) // 0 - 1
            self.immunityDurationOfNonPermanentImmunes = max(0, immunityDurationOfNonPermanentImmunes) // 0 - ...
        }
    }

    public struct FixedConfiguration {
        public let velocityAbs: Double = 0.15
        public let pointRadius: Double = 0.009
        public let squaredVelocityAbs: Double
        public let squaredPointRadius: Double

        init() {
            // Precompute to improve speed
            squaredVelocityAbs = pow(velocityAbs, 2)
            squaredPointRadius = pow(pointRadius, 2)
        }
    }

    // MARK: - Properties
    public let simulationDuration: Double

    public let behavior: BehaviorConfiguration
    public let illness: IllnessConfiguration
    public let immunity: ImmunityConfiguration
    public let fixed = FixedConfiguration()

    // MARK: - Initializers
    public init(
        simulationDuration: Double,
        behavior: BehaviorConfiguration,
        illness: IllnessConfiguration,
        immunity: ImmunityConfiguration
    ) {
        self.simulationDuration = min(1000, max(5, simulationDuration)) // 5 - 1000
        self.behavior = behavior
        self.illness = illness
        self.immunity = immunity
    }
}
