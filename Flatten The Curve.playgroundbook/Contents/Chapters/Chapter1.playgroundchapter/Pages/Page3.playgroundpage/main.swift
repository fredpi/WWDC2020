//#-hidden-code

import PlaygroundSupport

let configuration: Configuration

//#-end-hidden-code

/*:
 # 💀 The Lethality Paradox

 A thing that is quite interesting about viruses is the **lethality paradox**, as some call it.

 Isn't it astonishing that a disease like *Ebola* didn't spread all around the world while *COVID-19* is affecting our entire globe, even when the lethality of *COVID-19* (~ 1 %) **is much lower** than the lethality of *Ebola* (~ 50 %)?

 Well, one of the reasons certainly is that if most infected people die quickly, the chance for them to infect others is much smaller – **which makes diseases with a low (but still significant) lethality paradoxically more dangerous** in a global context.

On this page, you can try out a mutation of *Mock* with a **lethality of 100 %**, an incubation period of 2 seconds and an infectious duration of just half a second.

 - Note:
 As this is just a simulation, results vary more than they do in reality with much more people and a more complex distribution. With this specific configuration, the virus **may be gone immediately** or – if the points have bad luck – spread before. Try out yourself by running the code!
*/

/*:
 We're nearing the completion of this playground. [Go ahead to the final page](@next)!
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
        lethalityPercentage: 100%,
        incubationPeriod: 2,
        infectiousPercentage: 100%,
        infectiousDuration: 0.5
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
