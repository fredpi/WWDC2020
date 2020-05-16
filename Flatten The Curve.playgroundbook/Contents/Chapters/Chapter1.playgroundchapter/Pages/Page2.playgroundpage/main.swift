//#-hidden-code

import PlaygroundSupport

let configuration: Configuration

var movingPercentage: Double = 100%
var protectionPercentageAmongMoving: Double = 0%
var protectionPercentageAmongResting: Double = 0%
var infectiousSpeedReductionPercentage: Double = 0%

//#-end-hidden-code

/*:
 # 🚷 Social Distancing

 During the corona virus pandemic, experts have often been heard calling for us to practise **social distancing** as one of the most effective means to combat a virus. While this surely makes sense, we mostly don't have a real intuition how much of an impact social distancing can have. So let's try out!

 - Note:
 Please remember that each simulation is driven by random initial positions & movement; therefore unique. This is why you may get slightly differing results even with the same configuration.

You surely remember the simulation from the last page and how fast *Mock* could spread. We want to avoid this by **only letting 50 % of our points move**, so please give this setup a try by running the code.
*/

movingPercentage = 50%

/*:
 # 😷 More Protective Measures

 Well, this is certainly better, but still, **we're not quite there**. So, please set `takeMoreMeasures` to `true`, which will result in a much needed change of behavior:

 * Both 25 % of the moving points and 25 % of the resting points **wear protective gear** and can't be infected by the virus.
 * The points that are infectious are more cautious and **reduce their mobility by 75 %**.

After setting `takeMoreMeasures` to `true`, give it a run and look what happens!

 */

let takeMoreMeasures: Bool = false

if takeMoreMeasures {
    protectionPercentageAmongMoving = 25%
    protectionPercentageAmongResting = 25%
    infectiousSpeedReductionPercentage = 75%
}

/*:
 Now – **this really makes a difference**!

 There's certainly much more to try out here and you will be able to do it by yourself on the last page. But first, [let's have a look at the lethality paradox](@next)!
 */

//#-hidden-code

configuration = Configuration(
    simulationDuration: 20,
    behavior: .init(
        numberOfPoints: 150,
        movingPercentage: movingPercentage,
        protectionPercentageAmongMoving: protectionPercentageAmongMoving,
        protectionPercentageAmongResting: protectionPercentageAmongResting,
        infectiousSpeedReductionPercentage: infectiousSpeedReductionPercentage
    ),
    illness: .init(
        lethalityPercentage: 10%,
        incubationPeriod: 2,
        infectiousPercentage: 100%,
        infectiousDuration: 5
    ),
    immunity: .init(
        permanentImmunityPercentage: 100%,
        immunityDurationOfNonPermanentImmunes: 0
    )
)

PlaygroundPage.current.liveView = SimulationViewController(configuration: configuration) {
    PlaygroundPage.current.finishExecution()
}

//#-end-hidden-code
