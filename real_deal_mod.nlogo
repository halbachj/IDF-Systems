globals [num-interest-per-student num-societies-per-student]

breed [hums hum]
breed [stems stem]
breed [meds med]
breed [buss bus]

undirected-link-breed [course-friendships course-friendship]
undirected-link-breed [cross-course-friendships cross-course-friendship]
undirected-link-breed [cross-faculty-friendships cross-faculty-friendship]

links-own [friendship-contact-hours first-created]

turtles-own [personality course contact-hours emotional-capacity extroversion interests societies]

to-report calculate-society-difference [soc interest num]
  report ((soc - interest + 540) mod 360) - 180
end


to-report choose-society [ interest num ]
  report ((( round ( interest * (num / 360) ) ) / num ) * 360 )
end

to roll-interest [me interest]
  let m random-float 1 ; roll dice
  if m >= min-interest-roll [
    ask me [
      set interests lput interest interests
      set num-interest-per-student (num-interest-per-student + 1)
    ]
    ; check if a society with similar interests exists
    let soc choose-society interest num-societies
    let soc-diff calculate-society-difference soc interest num-societies
    if abs (soc-diff) < max-society-difference [
      ask me [
        set societies lput soc societies ; add the society to the list
        set num-societies-per-student (num-societies-per-student + 1)
      ]
    ]
  ]
end

to determine-interests [me]
  foreach (range num-interests) [ x -> roll-interest me x]
end

to setup
  clear-all
  let x-center world-width / 2
  let y-center world-height / 2
  let faculty-radius world-width / 4
  let course-radius faculty-radius / 2
  let agent-radius course-radius / 2

  let society-angular-difference (360 / num-societies)

  let stem-region 0
  let stem-course-offset 0

  let hum-region 90
  let hum-course-offset stem-course-offset + 4

  let med-region 180
  let med-course-offset hum-course-offset + 10

  let bus-region 270
  let bus-course-offset med-course-offset + 2

  let x-center-course-region faculty-radius * cos stem-region
  let y-center-course-region faculty-radius * sin stem-region
  let angular-distance 360 / 4
  let i stem-course-offset
  repeat 4 [
    let course-density random-normal 20 1
    let x-center-agent-region ( ( course-radius * cos (angular-distance * i) ) + x-center-course-region )
    let y-center-agent-region ( ( course-radius * sin (angular-distance * i) ) + y-center-course-region )
    let course-contact-hours round (random-normal stem-mean-contact-hours stem-contact-hour-distribution)
    create-stems course-density [
      set shape "circle"
      set color blue
      let angle (who * 360 / course-density)
      let x-coord agent-radius * cos angle + x-center-agent-region
      let y-coord agent-radius * sin angle + y-center-agent-region
      setxy x-coord y-coord
      set personality wrap-angle random-normal 0 sigma  ; Gaussian centered at 0°
      set course i
      set contact-hours ifelse-value course-contact-hours < 0 [0] [course-contact-hours] ; ensure that it is at least an online course...
      set extroversion random-normal extroversion-mean extroversion-distribution
      set emotional-capacity ( (random 10) * extroversion )
      ; determine interests
      set interests n-values 0 [0] ; create empty list
      set societies n-values 0 [0] ; create empty list
      determine-interests self ; chooses interests and societies
    ]
    set i (i + 1)
  ]

  set x-center-course-region faculty-radius * cos hum-region
  set y-center-course-region faculty-radius * sin hum-region
  set angular-distance 360 / 10
  set i hum-course-offset
  repeat 10 [
    let course-density random-normal 50 1
    let x-center-agent-region ( course-radius * cos (angular-distance * i) ) + x-center-course-region
    let y-center-agent-region ( course-radius * sin (angular-distance * i) ) + y-center-course-region
    let course-contact-hours round (random-normal hum-mean-contact-hours hum-contact-hour-distribution)
    create-hums course-density [
      set shape "circle"
      set color red
      let angle (who * 360 / course-density)
      let x-coord agent-radius * cos angle + x-center-agent-region
      let y-coord agent-radius * sin angle + y-center-agent-region
      setxy x-coord y-coord
      set personality wrap-angle random-normal 90 sigma  ; Gaussian centered at 0°
      set course i
      set contact-hours ifelse-value course-contact-hours < 0 [0] [course-contact-hours] ; ensure that it is at least an online course...
      set extroversion random-normal extroversion-mean extroversion-distribution
      set emotional-capacity ( (random 10) * extroversion )
      set interests n-values 0 [0] ; create empty list
      set societies n-values 0 [0] ; create empty list
      determine-interests self ; chooses interests and societies
    ]
    set i (i + 1)
  ]

  set x-center-course-region faculty-radius * cos med-region
  set y-center-course-region faculty-radius * sin med-region
  set angular-distance 360 / 2
  set i med-course-offset
  repeat 2 [
    let course-density random-normal 10 1
    let x-center-agent-region ( course-radius * cos (angular-distance * i) ) + x-center-course-region
    let y-center-agent-region ( course-radius * sin (angular-distance * i) ) + y-center-course-region
    let course-contact-hours round (random-normal med-mean-contact-hours med-contact-hour-distribution)
    create-meds course-density [
      set shape "circle"
      set color green
      let angle (who * 360 / course-density)
      let x-coord agent-radius * cos angle + x-center-agent-region
      let y-coord agent-radius * sin angle + y-center-agent-region
      setxy x-coord y-coord
      set personality wrap-angle random-normal 180 sigma  ; Gaussian centered at 0°
      set course i
      set contact-hours ifelse-value course-contact-hours < 0 [0] [course-contact-hours] ; ensure that it is at least an online course...
      set extroversion random-normal extroversion-mean extroversion-distribution
      set emotional-capacity ( (random 10) * extroversion )
      set interests n-values 0 [0] ; create empty list
      set societies n-values 0 [0] ; create empty list
      determine-interests self ; chooses interests and societies
    ]
    set i (i + 1)
  ]

  set x-center-course-region faculty-radius * cos bus-region
  set y-center-course-region faculty-radius * sin bus-region
  set angular-distance 360 / 4
  set i bus-course-offset
  repeat 4 [
    let course-density random-normal 20 1
    let x-center-agent-region ( course-radius * cos (angular-distance * i) ) + x-center-course-region
    let y-center-agent-region ( course-radius * sin (angular-distance * i) ) + y-center-course-region
    let course-contact-hours round (random-normal bus-mean-contact-hours bus-contact-hour-distribution)
    create-buss course-density [
      set shape "circle"
      set color yellow
      let angle (who * 360 / course-density)
      let x-coord agent-radius * cos angle + x-center-agent-region
      let y-coord agent-radius * sin angle + y-center-agent-region
      setxy x-coord y-coord
      set personality wrap-angle random-normal 270 sigma  ; Gaussian centered at 0°
      set course i
      set contact-hours ifelse-value course-contact-hours < 0 [0] [course-contact-hours] ; ensure that it is at least an online course...
      set extroversion random-normal extroversion-mean extroversion-distribution
      set emotional-capacity ( (random 10) * extroversion )
      set interests n-values 0 [0] ; create empty list
      set societies n-values 0 [0] ; create empty list
      determine-interests self ; chooses interests and societies
    ]
    set i (i + 1)
  ]

  ;ask turtles [set happy? false]

  reset-ticks
end

to-report wrap-angle [angle]
  report (angle mod 360)
end


to go
  let total-new-friends 0
  let total-cross-friends 0

  ask turtles [
    let me self
    ask one-of  other turtles [
      make-friend me self
    ]
  ]
  ask links [ ; break friendhips
    if check-friendship self [
      die
    ]
  ]

  tick
end

to-report check-friendship [friendship]
  if [first-created] of friendship = ticks [
    report false ; newly createx. let them be friends for at least one tick
  ]
  let friendship-length ticks - [first-created] of friendship
  let d random-float 1
  set d (d - friendship-length * 0.01)
  if d > 0.95 [
    report true ; kill friendship
  ]
  report false ; friendship survives
end

to make-friend [a b]
  if has-friend-capacity a and has-friend-capacity b [
    let success check-friendship-success a b
    if is-list? success [
      let dice-roll random-float friendship-roll
      if item 0 success < friendship-roll [
        ; we're friends now, nice
        create-friendship a b item 1 success
      ]
    ]
  ]
end

to create-friendship [a b our-contact-hours]
  ifelse [breed] of a != [breed] of b[
    ; wow not even in the same faculty/school
    ask a [
      create-cross-faculty-friendship-with b [
        set color pink
        set first-created ticks
        set friendship-contact-hours our-contact-hours
      ]
    ]
  ] [
    ifelse [course] of a = [course] of b [
      ; yay same course
      ask a [
        create-course-friendship-with b [
          set color [color] of a
          set first-created ticks
          set friendship-contact-hours our-contact-hours
        ]
      ]
    ] [
      ; yay different course
      ask a [
        create-cross-course-friendship-with b [
          set first-created ticks
          set friendship-contact-hours our-contact-hours
        ]
      ]
    ]
  ]
end

to-report check-friendship-success [a b]
  ; check if theyre already friends
  let are-friends-already false
  ask a [
    if link-neighbor? b [
      set are-friends-already true
    ]
  ]
  if are-friends-already [
    report false
  ]

  let our-contact-hours 0
  ifelse [breed] of a = [breed] of b [
    ifelse [course] of a = [course] of b [
      set our-contact-hours (([contact-hours] of a) + 2); use course contact hours and add 2
    ] [ ; not in the same course
      set our-contact-hours 2 ; set contact hours to just 2 if they are in the same faculty/school
    ]
  ] [ ; not of the same breed
    set our-contact-hours random-float general-hour-bonus ; set contact hours to 1 if they are not in thery faculty/school
  ]

  foreach [societies] of a [ x ->
    if member? x ([societies] of b) [
      set our-contact-hours ( our-contact-hours + 2) ; if same societies add another 2 contact hours
    ]
  ]

  let effective-contact-hours ((sqrt our-contact-hours) * ([extroversion] of a + [extroversion] of b))
  let pers-diff compare-personality a b

  if effective-contact-hours <= 0 [ ; you literally never seen them
    report false
  ]
  let chance pers-diff / effective-contact-hours
  report list chance effective-contact-hours
end

to-report has-friend-capacity [a]
  let num-friends-a 0
  ask a [
    set num-friends-a count link-neighbors
  ]
  report num-friends-a <= [emotional-capacity] of a
end

to-report compare-personality [a b]
  let raw-difference ([personality] of a - [personality] of b) mod 360
  let difference ifelse-value (raw-difference > 180) [360 - raw-difference] [raw-difference]
  report difference
end
@#$#@#$#@
GRAPHICS-WINDOW
819
10
2270
1462
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-55
55
-55
55
1
1
1
ticks
30.0

BUTTON
13
15
78
50
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

SLIDER
448
449
481
569
sigma
sigma
0
100
30.0
1
1
NIL
VERTICAL

PLOT
487
450
798
570
personality distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 360\nset-histogram-num-bars 360" ""
PENS
"default" 1.0 0 -13345367 true "" "histogram [personality] of stems"
"pen-1" 1.0 0 -2674135 true "" "histogram [personality] of hums"
"pen-2" 1.0 0 -10899396 true "" "histogram [personality] of meds"
"pen-3" 1.0 0 -7500403 true "" "histogram [personality] of buss"

SLIDER
449
582
482
777
extroversion-mean
extroversion-mean
0
1
0.2
0.001
1
NIL
VERTICAL

SLIDER
487
583
520
777
extroversion-distribution
extroversion-distribution
0
1
0.16
0.001
1
NIL
VERTICAL

PLOT
529
583
796
779
extroversion distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 1\nset-histogram-num-bars 100" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [extroversion] of turtles"

MONITOR
275
74
389
119
NIL
count turtles
0
1
11

BUTTON
150
16
213
49
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

SLIDER
274
124
446
157
num-societies
num-societies
1
50
25.0
1
1
NIL
HORIZONTAL

SLIDER
2
73
244
106
stem-mean-contact-hours
stem-mean-contact-hours
1
80
20.0
1
1
NIL
HORIZONTAL

SLIDER
1
113
244
146
stem-contact-hour-distribution
stem-contact-hour-distribution
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
3
165
241
198
hum-mean-contact-hours
hum-mean-contact-hours
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
1
205
241
238
hum-contact-hour-distribution
hum-contact-hour-distribution
0
10
7.0
1
1
NIL
HORIZONTAL

SLIDER
4
263
242
296
med-mean-contact-hours
med-mean-contact-hours
1
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
4
302
242
335
med-contact-hour-distribution
med-contact-hour-distribution
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
7
359
244
392
bus-mean-contact-hours
bus-mean-contact-hours
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
5
403
242
436
bus-contact-hour-distribution
bus-contact-hour-distribution
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
451
124
623
157
num-interests
num-interests
0
25
7.0
1
1
NIL
HORIZONTAL

SLIDER
274
168
447
201
min-interest-roll
min-interest-roll
0
1
0.39
0.01
1
NIL
HORIZONTAL

SLIDER
451
168
624
201
max-society-difference
max-society-difference
0
15
3.7
0.1
1
NIL
HORIZONTAL

MONITOR
392
74
503
119
NIL
num-interest-per-student / (count turtles)
2
1
11

MONITOR
506
75
623
120
NIL
num-societies-per-student / (count turtles)
2
1
11

SLIDER
271
215
456
248
general-hour-bonus
general-hour-bonus
0
10
1.9
0.1
1
NIL
HORIZONTAL

PLOT
8
635
208
785
cross-course-friendships
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count cross-course-friendships"

PLOT
213
468
413
618
course-friendships
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count course-friendships"

PLOT
211
634
411
784
cross-faculty-friendships
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count cross-faculty-friendships"

BUTTON
470
212
623
245
toggle course links
let is-hidden false\nask one-of course-friendships [\n  set is-hidden hidden?\n]\nifelse is-hidden [\n  ask course-friendships [\n    show-link\n  ]\n] [\n  ask course-friendships [\n    hide-link\n  ]\n]
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
470
254
625
287
toggle cross course links
let is-hidden false\nask one-of cross-course-friendships [\n  set is-hidden hidden?\n]\nifelse is-hidden [\n  ask cross-course-friendships [\n    show-link\n  ]\n] [\n  ask cross-course-friendships [\n    hide-link\n  ]\n]
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
472
295
626
328
toggle cross faculty links
let is-hidden false\nask one-of cross-faculty-friendships [\n  set is-hidden hidden?\n]\nifelse is-hidden [\n  ask cross-faculty-friendships [\n    show-link\n  ]\n] [\n  ask cross-faculty-friendships [\n    hide-link\n  ]\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
7
468
207
618
friendships
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count links"

SLIDER
272
252
451
285
friendship-roll
friendship-roll
0
10
6.3
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Testrun" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 200</exitCondition>
    <metric>count links</metric>
    <enumeratedValueSet variable="bus-courses">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stem-mean-contact-hours">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stem-course-density-distribution">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="med-course-density-distribution">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extroversion-mean">
      <value value="0.494"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-society-difference">
      <value value="3.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bus-contact-hour-distribution">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="faculty-hour-bonus">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-societies">
      <value value="24"/>
      <value value="1"/>
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="med-population">
      <value value="32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="society-hour-bonus">
      <value value="2.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stem-contact-hour-distribution">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="med-courses">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hum-population">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hum-course-density-distribution">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stem-population">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="med-mean-contact-hours">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="extroversion-distribution">
      <value value="0.16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stem-courses">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hum-mean-contact-hours">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hum-courses">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hum-contact-hour-distribution">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="med-contact-hour-distribution">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="course-hour-bonus">
      <value value="4.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bus-mean-contact-hours">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="general-hour-bonus">
      <value value="1.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-interests">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bus-population">
      <value value="27"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="friendship-roll">
      <value value="6.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-interest-roll">
      <value value="0.39"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bus-course-density-distribution">
      <value value="2"/>
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
