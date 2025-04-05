globals [num-interest-per-student num-societies-per-student]

breed [hums hum]
breed [stems stem]
breed [meds med]
breed [buss bus]

undirected-link-breed [course-friendships course-friendship]
undirected-link-breed [cross-course-friendships cross-course-friendship]

links-own [accumulated-contact-hours]

turtles-own [friends cross-friends personality course contact-hours emotional-capacity extroversion interests societies]

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
  let hum-course-offset stem-course-offset + stem-courses

  let med-region 180
  let med-course-offset hum-course-offset + hum-courses

  let bus-region 270
  let bus-course-offset med-course-offset + med-courses

  let x-center-course-region faculty-radius * cos stem-region
  let y-center-course-region faculty-radius * sin stem-region
  let angular-distance 360 / stem-courses
  let i stem-course-offset
  repeat stem-courses [
    let course-density random-normal stem-population stem-course-density-distribution
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
  set angular-distance 360 / hum-courses
  set i hum-course-offset
  repeat hum-courses [
    let course-density random-normal hum-population hum-course-density-distribution
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
  set angular-distance 360 / med-courses
  set i med-course-offset
  repeat med-courses [
    let course-density random-normal med-population med-course-density-distribution
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
  set angular-distance 360 / bus-courses
  set i bus-course-offset
  repeat bus-courses [
    let course-density random-normal bus-population bus-course-density-distribution
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
    ask other turtles [
      make-friend me self
    ]
  ]

  tick
end

to make-friend [a b]
  if has-friend-capacity a and has-friend-capacity b [
    if check-friendship-success a b [
      ; we're friends now, nice
      create-friendship a b
    ]
  ]

end

to create-friendship [a b]
  ifelse [course] of a = [course] of b [
    ; yay same course
    ask a [
      create-course-friendship-with b [set color [color] of a]
    ]
  ] [
    ; yay different course
    ask a [
      create-cross-course-friendship-with b
    ]
  ]
end

to-report check-friendship-success [a b]
  if member? b link-neighbors [
    report false
  ]
  let our-contact-hours 0
  ifelse [breed] of a = [breed] of b [
    ifelse [course] of a = [course] of b [
      set our-contact-hours ([contact-hours] of a) + 2; use course contact hours and add 2
    ] [ ; not in the same course
      set our-contact-hours 2 ; set contact hours to just 2 if they are in the same faculty/school
    ]
  ] [ ; not of the same breed
    set our-contact-hours 1 ; set contact hours to 1 if they are not in thery faculty/school
  ]

  foreach [societies] of a [ x ->
    if member? x [societies] of b [
      set our-contact-hours ( our-contact-hours + 2) ; if same societies add another 2 contact hours
    ]
  ]

  let effective-contact-hours ((sqrt our-contact-hours) * ([extroversion] of a + [extroversion] of b))
  let pers-diff compare-personality a b
  if effective-contact-hours <= 0 [ ; you literally never seen them
    report false
  ]
  let chance pers-diff / effective-contact-hours
  let dice-roll random 3

  if (chance < dice-roll) [
    report true
  ]
  report false
end

to-report has-friend-capacity [a]
  report [friends] of a <= [emotional-capacity] of a
end

to-report compare-personality [a b]
  let raw-difference ([personality] of a - [personality] of b) mod 360
  let difference ifelse-value (raw-difference > 180) [360 - raw-difference] [raw-difference]
  report difference
end
@#$#@#$#@
GRAPHICS-WINDOW
1016
10
2467
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
0
0
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
16
277
196
310
hum-population
hum-population
0
300
29.0
1
1
NIL
HORIZONTAL

SLIDER
206
277
401
310
hum-courses
hum-courses
0
35
2.0
1
1
NIL
HORIZONTAL

SLIDER
14
61
194
94
stem-population
stem-population
0
300
40.0
1
1
NIL
HORIZONTAL

SLIDER
204
61
399
94
stem-courses
stem-courses
0
35
2.0
1
1
NIL
HORIZONTAL

SLIDER
16
496
196
529
med-population
med-population
0
300
52.0
1
1
NIL
HORIZONTAL

SLIDER
206
496
401
529
med-courses
med-courses
0
35
3.0
1
1
NIL
HORIZONTAL

SLIDER
15
709
195
742
bus-population
bus-population
0
300
24.0
1
1
NIL
HORIZONTAL

SLIDER
205
709
400
742
bus-courses
bus-courses
0
35
3.0
1
1
NIL
HORIZONTAL

SLIDER
662
216
695
336
sigma
sigma
0
100
51.0
1
1
NIL
VERTICAL

PLOT
701
217
1012
337
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
16
101
397
134
stem-course-density-distribution
stem-course-density-distribution
0
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
15
319
398
352
hum-course-density-distribution
hum-course-density-distribution
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
15
535
401
568
med-course-density-distribution
med-course-density-distribution
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
16
751
399
784
bus-course-density-distribution
bus-course-density-distribution
0
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
663
349
696
544
extroversion-mean
extroversion-mean
0
1
0.5
0.001
1
NIL
VERTICAL

SLIDER
701
350
734
544
extroversion-distribution
extroversion-distribution
0
1
0.1
0.001
1
NIL
VERTICAL

PLOT
743
350
1010
546
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
661
62
775
107
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
660
112
832
145
num-societies
num-societies
0
100
6.0
1
1
NIL
HORIZONTAL

PLOT
16
138
320
258
stem-course-distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 stem-population * 2\nset-histogram-num-bars stem-population / 2" ""
PENS
"default" 10.0 1 -16777216 true "" "let result n-values 0 [0]\nlet students-per-course n-values stem-courses [0]\n\nask stems [\n  set students-per-course replace-item course students-per-course ( (item course students-per-course) + 1 ) ; count how many students are in each course\n  set result lput course result ; add the course id to a list\n]\n\nlet i 0\nlet n (length result)\nrepeat n [\n  let course-id (item i result)\n  set result replace-item i result (item course-id students-per-course)\n  set i (i + 1)\n]\n\n\n;show result\nhistogram result"

SLIDER
405
61
647
94
stem-mean-contact-hours
stem-mean-contact-hours
0
80
12.0
1
1
NIL
HORIZONTAL

SLIDER
404
101
647
134
stem-contact-hour-distribution
stem-contact-hour-distribution
0
100
3.0
1
1
NIL
HORIZONTAL

PLOT
323
138
649
258
stem-contact-hour-distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"; these values are more or less arbritrary but work out\nset-plot-x-range 0 80\nset-histogram-num-bars (stem-courses)" ""
PENS
"default" 10.0 1 -16777216 true "" "let contact-hours-per-course n-values stem-courses [0]\n\nlet i 0\nrepeat stem-courses [\n  let course-hours-list [contact-hours] of stems with [course = i]\n  if not empty? course-hours-list [\n    let hours one-of course-hours-list\n    set contact-hours-per-course replace-item i contact-hours-per-course hours\n  ]\n  set i (i + 1)\n]\n\n;show result\nhistogram contact-hours-per-course"

PLOT
16
355
320
475
hum-course-distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 hum-population * 2\nset-histogram-num-bars hum-population / 2" ""
PENS
"default" 10.0 1 -16777216 true "" "let result n-values 0 [0]\nlet students-per-course n-values hum-courses [0]\n\nask hums [\n  let id (course - stem-courses)\n  set students-per-course replace-item id students-per-course ( (item id students-per-course) + 1 ) ; count how many students are in each course\n  set result lput id result ; add the course id to a list\n]\n\nlet i 0\nlet n (length result)\nrepeat n [\n  let course-id (item i result)\n  set result replace-item i result (item course-id students-per-course)\n  set i (i + 1)\n]\n\n\n;show result\nhistogram result"

PLOT
325
356
646
476
hum-contact-hour-distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"; these values are more or less arbritrary but work out\nset-plot-x-range 0 80\nset-histogram-num-bars (hum-courses)" ""
PENS
"default" 10.0 1 -16777216 true "" "let contact-hours-per-course n-values hum-courses [0]\n\nlet i 0\nrepeat hum-courses [\n  let id (i + stem-courses)\n  let course-hours-list [contact-hours] of hums with [course = id]\n  if not empty? course-hours-list [\n    let hours one-of course-hours-list\n    set contact-hours-per-course replace-item i contact-hours-per-course hours\n  ]\n  set i (i + 1)\n]\n\n;show result\nhistogram contact-hours-per-course"

SLIDER
407
278
645
311
hum-mean-contact-hours
hum-mean-contact-hours
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
405
318
645
351
hum-contact-hour-distribution
hum-contact-hour-distribution
0
100
3.0
1
1
NIL
HORIZONTAL

PLOT
15
572
314
692
med-course-distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 med-population * 2\nset-histogram-num-bars med-population / 2" ""
PENS
"default" 10.0 1 -16777216 true "" "let result n-values 0 [0]\nlet students-per-course n-values med-courses [0]\n\nask meds [\n  let id (course - (stem-courses + hum-courses))\n  set students-per-course replace-item id students-per-course ( (item id students-per-course) + 1 ) ; count how many students are in each course\n  set result lput id result ; add the course id to a list\n]\n\nlet i 0\nlet n (length result)\nrepeat n [\n  let course-id (item i result)\n  set result replace-item i result (item course-id students-per-course)\n  set i (i + 1)\n]\n\n\n;show result\nhistogram result"

PLOT
319
573
642
693
med-contact-hour-distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"; these values are more or less arbritrary but work out\nset-plot-x-range 0 80\nset-histogram-num-bars (med-courses)" ""
PENS
"default" 10.0 1 -16777216 true "" "let contact-hours-per-course n-values med-courses [0]\n\nlet i 0\nrepeat med-courses [\n  let id (i + stem-courses + hum-courses)\n  let course-hours-list [contact-hours] of meds with [course = id]\n  if not empty? course-hours-list [\n    let hours one-of course-hours-list\n    set contact-hours-per-course replace-item i contact-hours-per-course hours\n  ]\n  set i (i + 1)\n]\n\n;show result\nhistogram contact-hours-per-course"

SLIDER
406
495
644
528
med-mean-contact-hours
med-mean-contact-hours
0
100
18.0
1
1
NIL
HORIZONTAL

SLIDER
406
534
644
567
med-contact-hour-distribution
med-contact-hour-distribution
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
406
709
643
742
bus-mean-contact-hours
bus-mean-contact-hours
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
406
752
643
785
bus-contact-hour-distribution
bus-contact-hour-distribution
0
100
4.0
1
1
NIL
HORIZONTAL

PLOT
16
789
307
939
bus-course-distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 bus-population * 2\nset-histogram-num-bars bus-population / 2" ""
PENS
"default" 10.0 1 -16777216 true "" "let result n-values 0 [0]\nlet students-per-course n-values bus-courses [0]\n\nask buss [\n  let id (course - (stem-courses + hum-courses + med-courses))\n  set students-per-course replace-item id students-per-course ( (item id students-per-course) + 1 ) ; count how many students are in each course\n  set result lput id result ; add the course id to a list\n]\n\nlet i 0\nlet n (length result)\nrepeat n [\n  let course-id (item i result)\n  show course-id\n  show i\n  set result replace-item i result (item course-id students-per-course)\n  set i (i + 1)\n]\n\n\n;show result\nhistogram result"

PLOT
311
790
643
940
bus-contact-hour-distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"; these values are more or less arbritrary but work out\nset-plot-x-range 0 80\nset-histogram-num-bars (bus-courses)" ""
PENS
"default" 10.0 1 -16777216 true "" "let contact-hours-per-course n-values bus-courses [0]\n\nlet i 0\nrepeat bus-courses [\n  let id (i + stem-courses + hum-courses + med-courses)\n  let course-hours-list [contact-hours] of buss with [course = id]\n  if not empty? course-hours-list [\n    let hours one-of course-hours-list\n    set contact-hours-per-course replace-item i contact-hours-per-course hours\n  ]\n  set i (i + 1)\n]\n\n;show result\nhistogram contact-hours-per-course"

SLIDER
837
112
1009
145
num-interests
num-interests
0
100
8.0
1
1
NIL
HORIZONTAL

SLIDER
660
156
833
189
min-interest-roll
min-interest-roll
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
837
156
1010
189
max-society-difference
max-society-difference
0
15
3.1
0.1
1
NIL
HORIZONTAL

MONITOR
778
62
889
107
NIL
num-interest-per-student / (count turtles)
2
1
11

MONITOR
892
63
1009
108
NIL
num-societies-per-student / (count turtles)
2
1
11

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
