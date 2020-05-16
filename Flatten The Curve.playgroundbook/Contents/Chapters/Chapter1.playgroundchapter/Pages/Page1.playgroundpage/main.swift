//#-hidden-code

import PlaygroundSupport

let configuration: Configuration

//#-end-hidden-code

/*:
 # 🦠 Introducing Mock

 This playground is all about *Mock*. *Mock* is a virus.

 Within the next 3 minutes, we will simulate its spread, trying to gain insights about how to deal with real viruses by having a look at:

* protective measures
* the lethality paradox
* ... and more

*/

/*:
 ## ⚙️ How it works

 To simulate the spread of *Mock*, moving points that may infect each other upon collision are used – **simulating real persons**!
 This builds on an idea first suggested by the [Washington Post](https://www.washingtonpost.com/graphics/2020/world/corona-simulator/), yet allowing a much more fine-grained configuration. Look forward to the last page where you can **configure the simulation all by yourself** if you want to!

 For you to get to know how the simulation looks and works, just try out a 20 second demo simulation **by running the code**, before we will dive into more details. Try to observe what happens to a **Susceptible** (⚪️) point when it gets in contact with an **Infectious** (🔴) point:

* At first, it becomes **Exposed** (light red), which means that is has the virus but isn't **Infectious** (🔴) yet.
* After 2 seconds (the so called incubation period), it turns **Infectious** (🔴) itself, threatening other **Susceptible** (⚪️) points.
* After the next 5 seconds, if it's lucky, it survives and gets **Immune** (🟢). Yet, at least in this example, there's a 10 % chance of becoming **Dead** (⚫️).

*/

/*:
 When the demo simulation is finished, let's go on and [examine the impact of different protective measures](@next).
 */

//#-hidden-code

configuration = Configuration(
    simulationDuration: 20,
    behavior: .init(
        numberOfPoints: 150,
        movingPercentage: 100%,
        protectionPercentageAmongMoving: 0%,
        protectionPercentageAmongResting: 0%,
        infectiousSpeedReductionPercentage: 0%
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
