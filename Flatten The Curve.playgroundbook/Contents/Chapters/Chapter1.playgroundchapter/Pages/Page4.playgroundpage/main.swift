//#-hidden-code

import PlaygroundSupport

let configuration: Configuration

//#-end-hidden-code

/*:
 # 🏁 The End

 We have reached the final page and time is probably running out – hopefully you were able to gain some insights from these simulations. **Stay healthy!**

 **Just in case** that you are interested in trying out your own configurations: You can do so below!

*/

/*:
 # 🔬 The Lab

 Edit the configuration below and give your ideas a run! Beyond extending the simulation duration, here are some suggestions in case you need inspiration:

 * You can define the percentage of points that **keeps its immunity forever** after having been sick. You can also set the percentage to *0%* and control after how many seconds **they lose their immunity again**. With a loss of immunity after some time, the result of the simulation will most certainly be **recurring infection waves** causing a mortality higher than the actual virus's lethality.
 * You can try out **which behavior change helps most** with containing the virus. Does a total slowdown of the infectious alone help with that goal?
 * What happens if **not every exposed point becomes infectious**? (You can control this via the `infectiousPercentage` property)
 * Which virus configurations do **look mild but turn out to be quite dangerous** in the end?

 - Important:
 Always keep in mind that this simulation doesn't aim to scientifically prove something but is rather here to give us an intuition of how a virus spreads and what helps with containing it. So while the results of this simulation of course aren't the **entire picture**, they still contain much **basic truths** that can help us with our understanding.
*/

configuration = Configuration(
    simulationDuration: 60, // Enter a value between 5 and 1000 (5...1000)
    behavior: .init(
        numberOfPoints: 150, // (5...200)
        movingPercentage: 80%, // (0%...100%)
        protectionPercentageAmongMoving: 0%, // (0%...100%)
        protectionPercentageAmongResting: 50%, // (0%...100%)
        infectiousSpeedReductionPercentage: 0% // (0%...100%)
    ),
    illness: .init(
        lethalityPercentage: 10%, // (0%...100%)
        incubationPeriod: 5, // (0...)
        // This is the percentage of exposed points that becomes infectious
        infectiousPercentage: 80%, // (lethalityPercentage...100%)
        infectiousDuration: 10 // (0...)
    ),
    immunity: .init(
        permanentImmunityPercentage: 0%, // (0%...100%)
        immunityDurationOfNonPermanentImmunes: 20// (0...)
    )
)

//#-hidden-code

PlaygroundPage.current.liveView = SimulationViewController(configuration: configuration) {
    PlaygroundPage.current.finishExecution()
}

//#-end-hidden-code
