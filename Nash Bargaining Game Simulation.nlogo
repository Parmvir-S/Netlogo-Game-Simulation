turtles-own [strategy
             payoff]


to setup
  clear-all

  ask patches [sprout 1 [  ; Before, we asked n-of the patches to create turtles.
    set shape "circle"     ; Now, we ask all patches to create turtles

    set strategy random 11 ; Random 11 generates a random integer from 0-10 (inclusive)
                           ; It's confusing but you always have to go one bigger
                           ; than the range you really want with the random function.
                           ; Here we use random numbers to set up the starting strategies
                           ; so the population will be different each time.
    recolor]]

  reset-ticks
end

to go
  changePop                       ; change population size
  ask turtles [
    play                          ; play is short for 'play the nash demand game'
    learn                         ; learn allows turtles to update their strategy after each interaction
    mutate
    recolor
  ]
  tick

end

to changePop
  if ticks mod birth_or_death_frequency = 0 [  ; every birth_or_death_frequency number of ticks call the
    deathBirthFunc                             ; deathBirthFunc
  ]
end

to deathBirthFunc
  ifelse death_or_birth = 0 [                               ; if death_or_birth is set to 0
      ask n-of number_of_deaths_or_births turtles [ die ]   ; then kill off number_of_deaths_or_births turtles
  ] [
    ask n-of number_of_deaths_or_births turtles [    ; if death_or_birth is set to 1
      hatch 1 [                                      ; have number_of_deaths_or_births turtles
        set shape "circle"                           ; hatch turtles with the basic setup - shape/strategy/recolor
        set strategy random 11
        recolor
      ]
    ]
  ]
end

to play
  let partner one-of other turtles ; 'let' defines a local variable. It's a good
                                   ; technique for keeping track of information as the
                                   ; complexity of your functions increases.
                                   ; This particular let command selects another
                                   ; turtle and calls it partner.

  let s2 [strategy] of partner ; Another let function.
                               ; Gives a name 's2' to the strategy of that partner
                               ; This time, we are selecting the property of an agent
                               ; rather than the agent itself. So we use the '[PROPERTY] of AGENT'
                               ; construction.

  if strategy + s2 > 10 [ ; if the demands add up to more than 10, no one gets anything
    set payoff 0
    ask partner [ ; This is a trick to manage reference. When netlogo executes 'play'
                  ; it asks each turtle individually to execute play. So you can imagine
                  ; we are 'inside' the turtle when all these commands run. But to get our
                  ; partner to change their score in the game, we need to also go 'inside'
                  ; the partner, if briefly. 'Ask partner' is the technique to do that.
      set payoff 0]]

  if strategy + s2 <= 10 [ ; if the demands add up to 10 or less, both players get what they demand
    set payoff strategy
    ask partner [
      set payoff s2]]

end

to learn
  let teacher one-of other turtles ; selects another turtle and calls it teacher
  let s2 [strategy] of teacher ; gives the name s2 to the teachers strategy
  let training-data [payoff] of teacher ; gives the name training-data to the teachers payoff

  if random-float 1 < (training-data - payoff) / 10 [ ; Copy the teacher's strategy with probability proportion to the difference in payoffs
                                                      ; This is the same random-float trick we saw in the previous model.
                                                      ; But instead of dividing by 100 (to turn a percent into a decimal) we divide by 10
                                                      ; because 10 is the maximium difference between to the two payoffs. If your partner
                                                      ; gets a 10 and you get a zero, you should definitely copy them. Otherwise, you only
                                                      ; copy them with some probability.
    set strategy s2]

end

to mutate
  ; generates a random floating point number
  ; compares the mutation rate (converted from a percent to a frequency)
  ; if mutation rate is higher, select a random new strategy
  if random-float 1 < (mutation_rate / 100) [
    set strategy random 11]

end

to recolor
  set color 90.9 + (strategy) ; As I mentioned, netlogo keeps track of colors with numbers. So you can either use color keywords
                              ; or plain numbers to assign colors. Here we set a baseline color (90.9 is a very dark blue)
                              ; and then increase the brightness based on their strategy. So strategy 0 players are basically black
                              ; strategy 5 players are neutral blue and strategy 10 players are basically white.

end

to-report fair?                                            ; this is new. It's called a reporter.
                                                           ; Most procedures do things. This a reporter just measures things.
  report count turtles with [strategy = 5] > count turtles - 5 ; This one check to see if every turtle has adopted strategy 5. If not, it reports
                                                           ; false. If so, it reports true.

end
@#$#@#$#@
GRAPHICS-WINDOW
68
32
382
347
-1
-1
27.82
1
10
1
1
1
0
0
0
1
-5
5
-5
5
1
1
1
ticks
30.0

BUTTON
165
383
228
416
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
268
384
331
417
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
425
51
749
336
Nash Demand Game Histogram
strategy
frequency
0.0
10.0
0.0
10.0
false
false
"set-plot-x-range 0 11\nset-plot-y-range 0 150\nset-histogram-num-bars 11" ""
PENS
"pen-1" 1.0 1 -7500403 true "" "histogram [strategy] of turtles"

MONITOR
68
377
125
422
NIL
fair?
17
1
11

SLIDER
429
383
746
416
mutation_rate
mutation_rate
0
100
0.0
.1
1
%
HORIZONTAL

SLIDER
569
441
765
474
birth_or_death_frequency
birth_or_death_frequency
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
572
493
776
526
number_of_deaths_or_births
number_of_deaths_or_births
0
10
10.0
1
1
NIL
HORIZONTAL

MONITOR
131
465
214
510
NIL
count turtles
17
1
11

SLIDER
381
463
553
496
death_or_birth
death_or_birth
0
1
1.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## MOTIVATION

The previous version of the model assumed that the world's population size is static or in other words remains constant. This is an unrealistic assumption to make because population size is a dynamic property that is constantly changing. One way we can incorporate dynamic fluctuations in population size is to add birth and death into the model's ecosystem. Fairness norms can be influenced by demographic changes in a number of ways. For example, consider a population that has grown quite large and has exhausted most of its food resources in the area. The individuals in this population must decide whether they want to allocate the available resources in a manner that satisfies the basic needs of the greatest number of people or to look out for their own best interest. I suspect that due to the scarcity of resources, most individuals in this situation will take the risk and utilize a high demand strategy to secure food for themselves and their loved ones. In contrast, individuals in a smaller population size that has an abundance of food might split the food more fairly simply because they know that they don’t need to compete for it. Therefore, I predict that larger populations (higher birth rate) will drive the model to fairness less often than smaller populations (higher death rate)


## IMPLEMENTATION

I modified the go function and added two of my own functions called changePop and deathBirthFunc. Before the agents are asked to play the Nash Demand game, the changePop function is called. The changePop function's effect is only triggered when the tick count reaches a certain value that is specified by the user via the birth_or_death_frequency slider. Since a tick is a standardized measure of time in Netlogo, this allows the user of the model to select how often birth or death should be activated. For example, if the birth_or_death_frequency value is set to 10, then every 10 ticks there will be either an increase or decrease in population size depending on the other slider values. When the changePop functions effect is activated, it simply calls the deathBirthFunc which is responsible for either removing agents from the population or adding agents to the population. If the death_or_birth slider is set to 0, then the number of individuals set by the number_of_deaths_or_births slider will be killed off from the population. Contrastingly, if the death_or_birth slider is set to 1, then the number of individuals specified by the number_of_deaths_or_births slider will be added to the population (individuals will be born). 

## HOW TO USE IT

Firstly, set the number_of_deaths_or_births slider value to 0 such that the population will remain static like the original model. Run the model repeatedly. In most cases, the model will come to a fair bargaining convention as indicated by the fair reporter. However, less frequently you will come across trials where some unfair conventions emerge. Specifically, you will see an equilibrium approximately around one agent demanding 6 and the other demanding 4. 

After running the original model, set the death_or_birth slider value to 1, birth_or_death_frequency value to 10 and the number_of_death_or_births value to 10. Run the model repeatedly. You should see that the population almost always reaches a fair convention. You see that almost all the individuals opt for the demand 5 strategy.

You can also run the model repeatedly with the death_or_birth slider value set to 0,  birth_or_death_frequency value to 10 and the number_of_death_or_births value to 5. You will see that the population reaches a fair convention very consistently and more often than the previous condition where the population size was increasing. 

Feel free to play around with the sliders and examine the models behavior.


## THINGS TO NOTICE

Keep an eye out on the histogram and the fairness reporter to check whether the population has converged on a fair demand agreement. If some time has gone by and the population has not reached that fair convention, then it is very likely that the population will never converge on the desired fairness norms. 

## THINGS TO TRY

I have added three additional sliders to this model:

birth_or_death_frequency: This is a way to control how often death/birth activates. I would suggest moving the slider to various values such as 0, 50 and 100. This will provide a good understanding of how the frequency of birth/death activation affects fairness norms.

death_or_birth: This slider simply allows you to switch between death and birth. If the value is set to 0 that means death has been activated and if the value is set to 1 that means birth has been activated. I suggest trying out both individually and then switching between the two in the same simulation. 

number_of_deaths_or_births: This slider gives the user an option to select the number of individuals that should be born or killed off. I have put a cap of 10 on this value, as any values larger than this results in the population either growing too fast or declining too fast. I suggest varying the values from low --> medium --> high. 

## ANALYSIS

After conducting several rounds of 100 simulations on the original model, it became clear that the population converges on fairness norms approximately 70% of the time. With an increasing population size, where people are being born (death_or_birth = 1, birth_or_death_frequency = 10, number_of_death_or_births = 10), the same results are achieved where fairness norms are converged upon roughly 70% of the time. However, with a decreasing population size, where people are dying (death_or_birth = 0, birth_or_death_frequency = 10, number_of_death_or_births = 5), the population converges on fairness norms approximately 80% of the time.

The simulations on this new model indicate that demographic changes have a large impact on fairness norms. When changes in population size due to death or birth are taken into account we see that the model behaves differently based on how large the population size is prior to the commencement of any Nash Demand game round. Specifically, the model analysis shows that smaller populations tend to have greater fairness norms than larger populations.

Firstly, the smaller populations tend to reach fairness norms more often because there are two components now working against poor demanding strategies. In the original model, after the play, when social learning was occurring, the individuals with the best strategies passed on their strategies to their partners. Now in the modified model, death can also remove individuals who on average tend to choose sub-optimal demand strategies. This results in a group of individuals in the population who are mostly on the same wavelength when it comes to choosing a fair demand strategy. However, if the death function were to remove more individuals with good strategies, then it is likely that the social learning aspect will still allow the population to converge on fairness norms roughly 70% of the time. Secondly, when the population increases in size, it introduces new agents to the population who have had their strategies randomized. This means that the game is largely played in the same way as the original model, just with more people. 

The results of this model show us that if we reduce the number of individuals who tend to have an unfair demand strategy, then populations can achieve fairness norms a greater percentage of the time. It can also be said that the population not achieving fairness norms 100% of the time reflects real life where there are greedy people who don’t think about others and only look out for their own best interest.

In many aspects, this model is still very unrealistic. Firstly, when the population size is increased via birth, the turtles simply hatch and give their offspring a random strategy. This isn’t the case in nature, as offspring tend to learn more about the world from their parents. Therefore, to improve this model in the future, a parent-to-child learning mechanism should be implemented. Secondly, while the interval between when death or birth is activated can be altered via the slider, the standardized tick time measurement makes it hard to generalize the results to a real life situation. Thirdly, for this model to be more realistic it must incorporate several other aspects such as learning speed, conformity, risk aversion, spatial structure and disaster. For example, the current world has individuals placed uniformly on the globe where each individual can play and learn from any other individual. This is not the case in real life, as we all live in different pockets of space and interact with only a small number of people. Furthermore, fairness norms will differ depending on where you are located geographically because of cultural differences.


## EXTENDING THE MODEL

Due to my limited knowledge in Netlogo I was not able to set a lower limit to the population size. So at this current time, the responsibility of keeping the population size above 0 has completely been handed over to the user of the model. In the future when extending and fixing this model, I would like to implement the logic of stopping the population decline once it hits a certain threshold. 

Furthermore, I would add a parent-to-child learning mechanism, where an individual teaches its offspring its own strategy. As of right now an individuals offspring gets its strategy assigned randomly which isn't the case in the real world. Most animals in the world including humans tend to learn from those that are around them in their immediate environment. However, learning is not equal from each person in the environment as we tend to trust our parents experiences and advice more than others. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="demo_1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="110"/>
    <exitCondition>fair?</exitCondition>
    <metric>fair?</metric>
    <enumeratedValueSet variable="mutation_rate">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="demo_2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="110"/>
    <exitCondition>fair?</exitCondition>
    <metric>fair?</metric>
    <enumeratedValueSet variable="mutation_rate">
      <value value="0.1"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="110"/>
    <exitCondition>fair?</exitCondition>
    <metric>fair?</metric>
    <enumeratedValueSet variable="mutation_rate">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="mutationTest" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="110"/>
    <exitCondition>fair?</exitCondition>
    <metric>fair?</metric>
    <enumeratedValueSet variable="mutation_rate">
      <value value="0.1"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="death_test" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="110"/>
    <exitCondition>fair?</exitCondition>
    <metric>fair?</metric>
    <enumeratedValueSet variable="mutation_rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death_or_birth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_deaths_or_births">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth_or_death_frequency">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
