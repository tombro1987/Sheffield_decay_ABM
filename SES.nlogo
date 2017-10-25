extensions [ gis csv profiler]
breed [ people person ] 
breed [ nodes node ]
breed [ vertices vertex ]
people-own [ zone sex age qhealth car ed NSSEC numdu98 costdly tpaste costTyp psycdisc everadsm highsug regular fluoride sweets ipout ncakes clnthg3 freqden evrfrqy rteacc totohip crime_score year_lost inc_est h_price
  count-down to-node speed cur-link target destination destination-entrance mynode step-in-path mypath last-stop birth-ticks ticktime memory]
globals [ csv filelist sheffield-east-dataset building-dataset building-dataset-crop road-dataset dentist-dataset shop-dataset FE-dataset centroid-dataset master-pointset 
  test-point dentist-location-dataset shop-location-dataset FE-location-dataset got_to_shop got_to_FE got_to_dentist_D got_to_shop_D got_to_FE_D got_to_dentist_O 
  got_to_shop_O got_to_FE_O schedule pathway3-count]
patches-own [ centroid? id entrance name CODE crime years_lost income hprice is-road? centroid?2 centroid?3 ]
vertices-own [ myneighbors dist done lastnode entrance? test]

;----------------------------------------------------------------------------------------------------------------------------------

to setup
  ca
  reset-ticks
  
  set sheffield-east-dataset gis:load-dataset "Sheffield_data/Sheffield_east_buffer.shp"
  set building-dataset gis:load-dataset "Sheffield_data/Sheffield_east_buildings.shp"
  set road-dataset gis:load-dataset "Sheffield_data/Sheffield_east_roads_buffer.shp" 
  set dentist-dataset gis:load-dataset "Sheffield_data/Sheffield_east_dentists.shp"
  set shop-dataset gis:load-dataset "Sheffield_data/Sheffield_east_shops.shp"
  set FE-dataset gis:load-dataset "Sheffield_data/Sheffield_east_FE.shp"
  
  set dentist-location-dataset gis:load-dataset "Sheffield_data/Sheffield_east_building_dentist.shp"
  set shop-location-dataset gis:load-dataset "Sheffield_data/Sheffield_east_shops_extra.shp"
  set FE-location-dataset gis:load-dataset "Sheffield_data/Sheffield_east_building_FE.shp"
  
  ;gis:set-world-envelope gis:envelope-of road-dataset

let road-envelope gis:envelope-of road-dataset

 let x-expansion (item 1 road-envelope - item 0 road-envelope) * 0.0001 
  let y-expansion (item 3 road-envelope - item 2 road-envelope) * 0.0001 
  let expanded-envelope (list (item 0 road-envelope - x-expansion) (item 1 road-envelope      + x-expansion) (item 2 road-envelope - y-expansion) (item 3 road-envelope + y-expansion)) 
  gis:set-world-envelope expanded-envelope 
  
  ;gis:set-drawing-color [230 230 230]    gis:fill sheffield-dataset 0 ; can just write colour name if easier
  ;gis:set-drawing-color [  0   0   0]    gis:draw sheffield-east-dataset 1
  ;gis:set-drawing-color [102 204 25]    gis:fill point-dataset 0
  ;gis:set-drawing-color orange    gis:draw dentist-dataset 1
  gis:set-drawing-color orange    gis:fill dentist-dataset 1
  ;gis:set-drawing-color grey   gis:fill building-dataset 0
  gis:set-drawing-color grey    gis:draw building-dataset 1 
  ;gis:set-drawing-color grey   gis:fill building-dataset-crop 0
  ;gis:set-drawing-color grey    gis:draw building-dataset-crop 1 
  ;gis:set-drawing-color [102 204 255]    gis:fill road-dataset 0
  gis:set-drawing-color [  0   0 255]    gis:draw road-dataset 1
  ;gis:set-drawing-color pink    gis:draw shop-dataset 1
  gis:set-drawing-color pink    gis:fill shop-dataset 1
  ;gis:set-drawing-color red  gis:draw centroid-dataset 1
  ;gis:set-drawing-color red  gis:fill centroid-dataset 1
  ;gis:set-drawing-color green gis:draw FE-dataset 1
  gis:set-drawing-color green gis:fill FE-dataset 1
  ;gis:set-drawing-color green gis:draw master-pointset 1
  ;gis:set-drawing-color green gis:fill master-pointset 1
  gis:set-drawing-color grey gis:draw dentist-location-dataset 1
  gis:set-drawing-color grey gis:draw shop-location-dataset 1
  gis:set-drawing-color grey gis:draw FE-location-dataset 1
  
  
create-the-people
  
   foreach gis:feature-list-of dentist-location-dataset
  [ let center-point gis:location-of gis:centroid-of ?
    ask patch item 0 center-point item 1 center-point [
      set centroid? true
      set id gis:property-value ? "id"
      ]]
  
  
   foreach gis:feature-list-of shop-location-dataset
  [ let center-point gis:location-of gis:centroid-of ?
    ask patch item 0 center-point item 1 center-point [
      set centroid?2 true
      set id gis:property-value ? "id"
      ]]
  

   foreach gis:feature-list-of FE-location-dataset
  [ let center-point gis:location-of gis:centroid-of ?
    ask patch item 0 center-point item 1 center-point [
      set centroid?3 true
      set id gis:property-value ? "id"
      ]]  
  
;venice-setup
gmu-setup

end  


;;------------------------------ Testing probabilities/differing centroids by seperate functions, by differing groups (e.g. Ed, NS-SEC) -------------------------------------------
 
  
 to move3
   move-degree
   move-other
   apply-domain2
   apply-domain3
   apply-domain4
   if ticks = 730 [stop]
   tick
 end 
   
   
to move-degree 
  let prob-degree random-float 1.0
  if prob-degree <= 0.2
  [
    move-dentist-degree
  ]
  if (prob-degree > 0.2) and (prob-degree < 0.8)
  [
    move-shops-degree
  ]
  if prob-degree >= 0.8
  [
    move-FE-degree
  ]
end   
 
   to move-dentist-degree  
    ask people[
      if ed = 1[     ; degree
    if destination = nobody [
       ask people [
       set destination one-of patches with [centroid? = true]
       set destination-entrance [entrance] of destination
       while [destination-entrance = mynode] [set destination one-of patches with [centroid?2 = true or centroid?3 = true] set destination-entrance [entrance] of destination ]
       ;;select shortest path
       path-select    
    ]
  ]
      ]
    ]
    ask people [
    ifelse xcor != [xcor] of destination-entrance or ycor != [ycor] of destination-entrance [
    move-to item step-in-path mypath
    set step-in-path step-in-path + 1
    ]
   [ ;move-to destination 
    set last-stop destination
    set destination nobody set mynode destination-entrance set got_to_dentist_D got_to_dentist_D + 1]  ;;arrive and select new destination
 ]
end
 
to move-shops-degree
  ask people[    
    if ed = 1[  ; degree
    if destination = nobody [
       ask people [
       set destination one-of patches with [centroid?2 = true]
       set destination-entrance [entrance] of destination
       while [destination-entrance = mynode] [set destination one-of patches with [centroid? = true or centroid?3 = true] set destination-entrance [entrance] of destination ]
       ;;select shortest path
       path-select    
    ]]
    ]
  ]
    
    ask people [
    ifelse xcor != [xcor] of destination-entrance or ycor != [ycor] of destination-entrance [
    move-to item step-in-path mypath
    set step-in-path step-in-path + 1
    ]
   [ ;move-to destination 
    set last-stop destination
    set destination nobody set mynode destination-entrance set got_to_shop_D got_to_shop_D + 1]  ;;arrive and select new destination
 ]
end

to move-FE-degree ; do you need to get rid of this? Do people with degrees take up apprenticehips and traineeships as well?     
  ask people[ 
    if ed = 1 and age = 2[
    if destination = nobody [
       ask people [
       set destination one-of patches with [centroid?3 = true]
       set destination-entrance [entrance] of destination
       while [destination-entrance = mynode] [set destination one-of patches with [centroid?2 = true or centroid? = true] set destination-entrance [entrance] of destination]
       ;;select shortest path
       path-select     
  ]]
    ]
  ]
   
   ask people [
    ifelse xcor != [xcor] of destination-entrance or ycor != [ycor] of destination-entrance [
    move-to item step-in-path mypath
    set step-in-path step-in-path + 1
    ]
   [ ;move-to destination 
    set last-stop destination
    set destination nobody set mynode destination-entrance set got_to_FE_D got_to_FE_D + 1]  ;;arrive and select new destination
 ]
end
 
 
to move-other
  let prob-other random-float 1.0
  if prob-other <= 1.0
  [ 
    move-dentist-other
  ]
  if (prob-other > 0.1) and (prob-other <= 0.9)
  [
    move-shops-other
  ]
  if prob-other > 0.9
  [
    move-FE-other
  ]
end
 
 
to move-dentist-other 
    ask people[
      if ed = 2[     ; non-degree
    if destination = nobody [
       ask people [
       set destination one-of patches with [centroid? = true]
       set destination-entrance [entrance] of destination
       while [destination-entrance = mynode] [set destination one-of patches with [centroid?2 = true or centroid?3 = true] set destination-entrance [entrance] of destination  ]
       ;;select shortest path
       path-select     
    ]
  ]
      ]
    ]
    ask people [
    ifelse xcor != [xcor] of destination-entrance or ycor != [ycor] of destination-entrance [
    move-to item step-in-path mypath
    set step-in-path step-in-path + 1
    ]
   [ ;move-to destination 
    set last-stop destination
    set destination nobody set mynode destination-entrance set got_to_dentist_O got_to_dentist_O + 1]  ;;arrive and select new destination
 ]
end 
 
to move-shops-other
  ask people[    
    if ed = 2[  ; non-degree
    if destination = nobody [
       ask people [
       set destination one-of patches with [centroid?2 = true]
       set destination-entrance [entrance] of destination
       while [destination-entrance = mynode] [set destination one-of patches with [centroid? = true or centroid?3 = true] set destination-entrance [entrance] of destination]
       ;;select shortest path
       path-select    
    ]]
    ]
  ]
    
    ask people [
    ifelse xcor != [xcor] of destination-entrance or ycor != [ycor] of destination-entrance [
    move-to item step-in-path mypath
    set step-in-path step-in-path + 1
    ]
   [ ;move-to destination 
    set last-stop destination
    set destination nobody set mynode destination-entrance set got_to_shop_O got_to_shop_O + 1]  ;;arrive and select new destination
 ]
end 
 
 
to move-FE-other    
  ask people[ 
    if ed = 2 and age = 1[  ; non-degree + 16-24
    if destination = nobody [
       ask people [
       set destination one-of patches with [centroid?3 = true]
       set destination-entrance [entrance] of destination
       while [destination-entrance = mynode] [set destination one-of patches with [centroid?2 = true or centroid? = true] set destination-entrance [entrance] of destination]
       ;;select shortest path
       path-select    
  ]]
    ]
  ]
   
   ask people [
    ifelse xcor != [xcor] of destination-entrance or ycor != [ycor] of destination-entrance [
    move-to item step-in-path mypath
    set step-in-path step-in-path + 1
    ]
   [ ;move-to destination 
    set last-stop destination
    set destination nobody set mynode destination-entrance set got_to_FE_O got_to_FE_O + 1]  ;;arrive and select new destination
 ]
end 
 
;;;;;;;;;;;;;;;;;;;;;;
;;;---- THEORY ----;;;-------------------------------------------------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Domain 2 ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; D2P1 - Material circumstances -> financial constraints -> stress -> smoking -> OHI ;;; Not sure about this one... ;;;;;

to d2p1
    if ticks mod 7 = 0[
    ifelse h_price <= 88564 and costdly = 1
    [ set psycdisc psycdisc + 0.01]
    [ set psycdisc psycdisc - 0.01]
    ]
    add-smoking
  d2p1-effect
end

to add-smoking
    if ticks mod 7 = 0[
      ifelse psycdisc > 3
      [set everadsm everadsm - 0.01]
      [set everadsm everadsm + 0.01]
    ]
end

to d2p1-effect
    if ticks mod 7 = 0[
      ifelse everadsm < 2 
      [set numdu98 numdu98 + 0.01]
      [set numdu98 numdu98 - 0.01]
    ]
end


;;;;; D2P2 - Material circumstances -> financial constraints -> diet -> sugar/nutrition -> OHI ;;;;;

to d2p2
    if ticks mod 7 = 0[
      ifelse h_price < 88564 and costdly = 1
      [set costtyp costtyp - 0.01] ; technically, diet (or cakes eaten) should be in this the step before highsug is added, but does that really make sense?
      [set costtyp costtyp + 0.01] ; i.e. does your financial constraint mean you would eat more cakes, in order to increase sugar levels? Not sure...
    ]
    d2p2-effect1
    d2p2-effect2
    d2p2-effect3
end

to d2p2-effect1
  if ticks mod 7 = 0 [
    ifelse costtyp < 2
    [set ncakes ncakes - 0.01]
    [set ncakes ncakes + 0.01]
  ]
end

to d2p2-effect2
  if ticks mod 7 = 0[
    ifelse ncakes < 3
    [set highsug highsug - 0.01]
    [set highsug highsug + 0.01]
  ]
end

to d2p2-effect3
  if ticks mod 7 = 0[
    ifelse highsug < 2
    [set numdu98 numdu98 + 0.01]
    [set numdu98 numdu98 - 0.01]
  ]
end

;;;;; D2P3 - Material circumstances -> financial constraints -> Knowledge (dental) -> health habits -> OHI ;;;;;

to d2p3
    if ticks mod 7 = 0[
      ifelse h_price < 88564 and costdly = 1
      [set fluoride fluoride + 0.01]
      [set fluoride fluoride - 0.01]
    ]
    d2p3-effect
end

to d2p3-effect
  if ticks mod 7 = 0[
    ifelse fluoride < 2 and regular = 1 ; the attendance variable is considered alongside the fluoride variable here, as it is not a variable that increases in quite the same way. You cant just suddenly
    [set numdu98 numdu98 - 0.01] ; adjust someones attendance (which happens at most every 6 months) at a particular point in time.
    [set numdu98 numdu98 + 0.01]
  ]
end

to apply-domain2
  ask people[ 
  d2p1
  d2p2
  d2p3
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Domain 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; D3P1 - Employment -> social hierarchy position -> OHI ;;;;;

to d3p1
  if ticks mod 14 = 0[
    ifelse nssec = 8 and inc_est <= 491.8  [ ; gone for this option for income rather than 'influence-of-income' slider - the slider option doesn't consider that actual value of the income variable, and applies it equally regardless of income level...
      set numdu98 numdu98 + 0.01]
    [set numdu98 numdu98 - 0.01]
  ]
end

;;;;; D3P2 - Education -> social hierarchy positions -> OHI ;;;;;

to d3p2
 if ticks mod 14 = 0 [ 
    ifelse ed = 2
    [set numdu98 numdu98 + 0.01] ; + influence-of-FE?
    [set numdu98 numdu98 - 0.01]
  ]
end


; D3P3 - Education -> dental knowledge -> damaging behaviours -> OHI

to d3p3
    if [pcolor] of patch-here = green [
        ifelse ed = 1
        [set fluoride fluoride - 0.01 - influence-of-FE]
        [set fluoride fluoride + 0.01 + influence-of-FE]
      ]
      d3p3-effect1
      d3p3-effect2
end

to d3p3-effect1
  if ticks mod 7 = 0 [
      ifelse fluoride < 2
      [set sweets sweets + 0.01]
      [set sweets sweets - 0.01]
    ]
end

to d3p3-effect2
  if ticks mod 7 = 0[
    ifelse sweets < 3 
    [set numdu98 numdu98 + 0.01]
    [set numdu98 numdu98 - 0.01]
  ]
end

;;;;; D3P4 - Shop -> diet(sugar) -> damaging behaviours -> OHI ;;;;;

to d3p4
  ask people[
    if [pcolor] of patch-here = pink [
      ifelse NSSEC = 8
      [set sweets sweets - 0.01 - influence-of-shops]
      [set sweets sweets + 0.01 + influence-of-shops]
      ]
      d3p4-effect1
      d3p4-effect2
    ]
end

to d3p4-effect1
  if ticks mod 7 = 0 [
      ifelse sweets < 3
      [set highsug highsug - 0.01]
      [set highsug highsug + 0.01]
    ]
end

to d3p4-effect2
  if ticks mod 7 = 0 [
    ifelse highsug < 2
    [set numdu98 numdu98 + 0.01]
    [set numdu98 numdu98 - 0.01]
  ]
end

;;;;; D3P5 - Dental service usage -> associated benefits/knowledge -> OHI ;; think this needs some work to get the two functions working together ;;;;;

to d3p5
    if [pcolor] of patch-here  = yellow [
        ifelse freqden = 1
        [set fluoride fluoride - 0.01 - influence-of-dentist]
        [set fluoride fluoride + 0.01 + influence-of-dentist]
      ]
      add-lag2
end

to add-lag2
  if ticks mod 7 = 0 [
      ifelse fluoride < 2
      [set numdu98 numdu98 - 0.01]
      [set numdu98 numdu98 + 0.01]
    ]
end

to apply-domain3 ; need a way to even out the decay score - will only grow unless you have a function to reduce decay in some people - not realistic but will help model
 ask people[
 d3p1
 d3p2
 d3p3
 d3p4
 d3p5
 ]
end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Domain 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; D4P1 - Health behaviours -> diet-> sugar/nutrition -> OHI ;;;;;

to d4p1
    if ticks mod 14 = 0[
      ifelse year_lost > 75.09
      [set ncakes ncakes - 0.01]
      [set ncakes ncakes + 0.01]
    ]
   d4p1-sugar
   d4p1-numdu98 
end

to d4p1-sugar
    if ticks mod 14 = 0[
      ifelse ncakes < 3 ; it makes sense to include cake consumption here as it relates to health behaviours, which makes more sense than being associated with financial constraints
      [set highsug highsug - 0.01]
      [set highsug highsug + 0.01]
    ]
end

to d4p1-numdu98
  if ticks mod 14 = 0[
    ifelse highsug < 2
    [set numdu98 numdu98 + 0.01]
    [set numdu98 numdu98 - 0.01]
  ]
end


;;;;; D4P2 - Health behaviours -> oral health habits -> OHI ;;;;;

to d4p2
  if ticks mod 14 = 0[
    ifelse year_lost > 75.09
    [set clnthg3 clnthg3 + 0.01]
    [set clnthg3 clnthg3 - 0.01]
  ]
  d4p2-clnthg3
end

to d4p2-clnthg3
    if ticks mod 14 = 0[
      ifelse Clnthg3 > 1
      [set numdu98 numdu98 + 0.01]
      [set numdu98 numdu98 - 0.01]
    ]
end



;;;;; D4P3 - Health behaviours -> attendance -> knowledge -> OHI ;;;;;

to d4p3
  if ticks mod 14 = 0[
    ifelse year_lost > 75.09 and freqden > 2
    [set fluoride fluoride + 0.01]
    [set fluoride fluoride - 0.01]
  ]
  d4p3-tbrush
  d4p3-numdu98
end

to d4p3-tbrush
  if ticks mod 14 = 0[
    ifelse fluoride < 2
    [set clnthg3 clnthg3 - 0.01]
    [set clnthg3 clnthg3 + 0.01]
  ]
end

to d4p3-numdu98
  if ticks mod 14 = 0[
    ifelse clnthg3 < 2
    [set numdu98 numdu98 - 0.01]
    [set numdu98 numdu98 + 0.01]
  ]
end


;;;;; D4P4 - Social capital -> acquired dental knowledge -> OHI ;;;;;

to d4p4
  if ticks mod 7 = 0[
    ifelse crime_score > 0.24
    [set fluoride fluoride + 0.01]
    [set fluoride fluoride - 0.01]
  ]
end

to d4p4-numdu98
    if ticks mod 7 = 0[
      ifelse fluoride < 2
      [set numdu98 numdu98 - 0.01]
      [set numdu98 numdu98 + 0.01]
    ]
end


;;;;; D4P5 - Social capital -> Healthy behavioural norms -> OHI ;;;;;

to d4p5
  if ticks mod 7 = 0[
    ifelse crime_score > 0.24 and regular > 2
    [set numdu98 numdu98 + 0.01]
    [set numdu98 numdu98 - 0.01]
  ]
end

;;;;; D4P6 - Social capital -> stress -> smoking -> OHI ;;;;;

to d4p6
    if ticks mod 7 = 0[
    ifelse crime_score > 0.24
    [ set psycdisc psycdisc + 0.01]
    [ set psycdisc psycdisc - 0.01]
    ]
    d4p6-smoking
  d4p6-numdu98
end

to d4p6-smoking
    if ticks mod 7 = 0[
      ifelse psycdisc > 3
      [set everadsm everadsm - 0.01]
      [set everadsm everadsm + 0.01]
    ]
end

to d4p6-numdu98
    if ticks mod 7 = 0[
      ifelse everadsm < 2
      [set numdu98 numdu98 + 0.01]
      [set numdu98 numdu98 - 0.01]
    ]
end


to apply-domain4
  ask people[
  d4p1
  d4p2
  d4p3
  d4p4
  d4p5
  d4p6
  ]
end

;;-------------------------------------- creating the people -------------------------------------------------------------------------  
  
to create-the-people
  
  create-people 8524 [ set color blue set shape "person" set size 0.2 set count-down 15 set birth-ticks ticks set memory (list patch-here) ] ; 8524
  
  ;file-open "Sheffield_data/east_sheffield_cluster_nofactor_master_SAMPLE_ten.csv"
  ;file-open "Sheffield_data/east_sheffield_cluster_nofactor_master_SAMPLE.csv"
  file-open "Sheffield_data/east_sheffield_cluster_nofactor_master_FULL.csv"
  
  while [not file-at-end? ][
    
    set csv file-read-line
    set csv word csv ","
    
    set filelist []
    
    while [ not empty? csv][
      let $x position "," csv
      let $item substring csv 0 $x
    
         carefully [set $item read-from-string $item][]
         set filelist lput $item filelist
         set csv substring csv ($x + 1) length csv
    ]
    
    ask person item 1 filelist[
      set zone item 2 filelist
      set sex item  3 filelist
      set age item 4 filelist
      set qhealth item 5 filelist
      set car item 6 filelist
      set ed item 7 filelist
      set nssec item 8 filelist
      set numdu98 item 9 filelist
      set costdly item 10 filelist
      set tpaste item 11 filelist
      set costTyp item 12 filelist
      set psycdisc item 13 filelist
      set everadsm item 14 filelist
      set highsug item 15 filelist
      set regular item 16 filelist
      set fluoride item 17 filelist
      set sweets item 18 filelist
      set ipout item 19 filelist
      set ncakes item 20 filelist
      set clnthg3 item 21 filelist
      set freqden item 22 filelist
      set evrfrqy item 23 filelist
      set rteacc item 24 filelist
      set totohip item 25 filelist
      set crime_score item 26 filelist
      set year_lost item 27 filelist
      set inc_est item 28 filelist
      set h_price item 29 filelist
    ]
  ]
;  ask people [
;    if zone = 1
;    [setxy 529 513
;    ]
;  ]   ; create a point datafile with a key for each point - then tell people to start on the point which matches to their key...?
file-close-all
display
  
end

;;--------------------------------- additional parts of the setup procedure (here due to the sequence in which they're called - ?) ----------------------------------------------------

to add-people
  ask people [set destination nobody set last-stop nobody
                                         set mynode one-of vertices move-to mynode]
end

to delete-duplicates
    ask vertices [
    if count vertices-here > 1[
      ask other vertices-here [
        
        ask myself [create-links-with other [link-neighbors] of myself]
        die] 
      ]
    ]

end  
  
to delete-not-connected
   ask vertices [set test 0]
 ask one-of vertices [set test 1]
 repeat 500 [
   ask vertices with [test = 1]
   [ask myneighbors [set test 1]]]
 ask vertices with [test = 0][die]
 
end  
  
;;----------------------------------------- the A* path algorithm thing used in the GMU model ---------------------------------------------------------  
  
to path-select
     
     ;;use the A-star algorithm to find the shortest path (shortest in terms of distance)
     
     set mypath [] set step-in-path 0
     
     ask vertices [set dist 99999 set done 0 set lastnode nobody set color brown]
     

     ask mynode [
       set dist 0 ] ;;distance to original node is 0
  

    while [count vertices with [done = 0] > 0][   
      ask vertices with [dist < 99999 and done = 0][
         ask myneighbors [
           let dist0 distance myself + [dist] of myself    ;;renew the shorstest distance to this point if it is smaller
           if dist > dist0 [set dist dist0 set done 0 ;;done=0 if dist renewed, so that it will renew the dist of its neighbors
             set lastnode myself]  ;;record the last node to reach here in the shortest path
           ;set color red  ;;all roads searched will get red
           ]  
         set done 1  ;;set done 1 when it has renewed it neighbors
      ]]
     
     ;print "Found path"
     
     
     ;;put nodes in shortest path into a list
     let x destination-entrance
     
     while [x != mynode] [
       if show_path? [ask x [set color yellow] ] ;;highlight the shortest path
       set mypath fput x mypath
       set x [lastnode] of x ]
end  

;;---------------------------------- ;; venice setup procedure ;; --------------------------------------

to venice-setup


setup-paths-graph
  

;delete-duplicates

ask vertices [set myneighbors link-neighbors]
delete-not-connected
ask vertices [set myneighbors link-neighbors]

ask patches with [centroid? = true][set entrance min-one-of vertices in-radius 50 [distance myself] 
    ask entrance [set entrance? true]
    if show_nodes? [ask vertices [set hidden? false]]
    if show_entrances? [ask entrance [set hidden? false set shape "star" set color black set size 0.5]]]

ask patches with [centroid?2 = true][set entrance min-one-of vertices in-radius 50 [distance myself] 
    ask entrance [set entrance? true]
    if show_nodes? [ask vertices [set hidden? false]]
    if show_entrances? [ask entrance [set hidden? false set shape "star" set color black set size 0.5]]]

ask patches with [centroid?3 = true][set entrance min-one-of vertices in-radius 50 [distance myself] 
    ask entrance [set entrance? true]
    if show_nodes? [ask vertices [set hidden? false]]
    if show_entrances? [ask entrance [set hidden? false set shape "star" set color black set size 0.5]]]

add-people

  set got_to_dentist_D 0
  set got_to_shop_D 0
  set got_to_FE_D 0
  set got_to_dentist_O 0
  set got_to_shop_O 0
  set got_to_FE_O 0
  
ask links [set thickness 0.001 set color orange]

ask patches [set pcolor white]
;  ask patches gis:intersecting test-point
;  [set pcolor orange]
;  ask patches gis:intersecting shop-dataset
;  [set pcolor green]
;  ask patches gis:intersecting FE-dataset
;  [set pcolor pink]

ask patch -7 1 [
  set pcolor yellow
]
ask patch -7 0 [
  set pcolor pink
]
ask patch 3 -7 [
  set pcolor green
]
ask patch 7 -12 [
  set pcolor pink
]
ask patch 7 -5 [
  set pcolor pink
]
ask patch 10 -5 [
  set pcolor pink
]
ask patch 10 14 [
  set pcolor green
]
ask patch -4 -5 [
  set pcolor pink
]
ask patch 0 -6 [
  set pcolor pink
]


; let path-m user-new-file
; if not is-string? path-m [stop]
; movie-start "test.mov"
; movie-grab-view
; repeat 20 [
;   move3
;   movie-grab-view
; ]
; movie-close
 
 
end  


to setup-paths-graph
  set-default-shape nodes "circle"
  foreach polylines-of road-dataset node-precision [
    (foreach butlast ? butfirst ? [ if ?1 != ?2 [ ;; skip nodes on top of each other due to rounding
      let n1 new-vertex-at first ?1 last ?1
      let n2 new-vertex-at first ?2 last ?2
      ask n1 [create-link-with n2]
    ]])
  ]
  ask vertices [hide-turtle]
end
to-report new-vertex-at [x y] ; returns a node at x,y creating one if there isn't one there.
  let n vertices with [xcor = x and ycor = y]
  ifelse any? n [set n one-of n] [create-vertices 1 [setxy x y set size 2 set n self]]
  report n
end

to-report polylines-of [dataset decimalplaces]
  let polylines gis:feature-list-of dataset                              ;; start with a features list
  set polylines map [first ?] map [gis:vertex-lists-of ?] polylines      ;; convert to virtex lists
  set polylines map [map [gis:location-of ?] ?] polylines                ;; convert to netlogo float coords.
  set polylines remove [] map [remove [] ?] polylines                    ;; remove empty poly-sets .. not visible
  set polylines map [map [map [precision ? decimalplaces] ?] ?] polylines        ;; round to decimalplaces
    ;; note: probably should break polylines with empty coord pairs in the middle of the polyline
  report polylines ;; Note: polylines with a few off-world points simply skip them.
end


;;------------------------------------ ;; gmu setup procedure ;; --------------------------------------------------------

to gmu-setup
  
foreach gis:feature-list-of road-dataset[
  
  foreach gis:vertex-lists-of ? ; for the road feature, get the list of vertices
       [
        let previous-node-pt nobody
        
        foreach ?  ; for each vertex in road segment feature
         [ 
          let location gis:location-of ?
          if not empty? location
           [
            ;ifelse any? vertices with [(xcor = item 0 location and ycor = item 1 location) ] ; if there is not a road-vertex here already
             ;[]
             ;[
             create-vertices 1
               [set myneighbors n-of 0 turtles ;;empty
                set xcor item 0 location
                set ycor item 1 location
                set size 0.2
                set shape "circle"
                set color brown
                set hidden? true
      
     
              ;; create link to previous node
              ifelse previous-node-pt = nobody
                 [] ; first vertex in feature
                 [create-link-with previous-node-pt] ; create link to previous node  
                  set previous-node-pt self]
               ;]
           ]]] ]

delete-duplicates

ask vertices [set myneighbors link-neighbors]
delete-not-connected
ask vertices [set myneighbors link-neighbors]

ask patches with [centroid? = true][set entrance min-one-of vertices in-radius 50 [distance myself] 
    ask entrance [set entrance? true]
    if show_nodes? [ask vertices [set hidden? false]]
    if show_entrances? [ask entrance [set hidden? false set shape "star" set size 0.5]]]

ask patches with [centroid?2 = true][set entrance min-one-of vertices in-radius 50 [distance myself] 
    ask entrance [set entrance? true]
    if show_nodes? [ask vertices [set hidden? false]]
    if show_entrances? [ask entrance [set hidden? false set shape "star" set size 0.5]]]

ask patches with [centroid?3 = true][set entrance min-one-of vertices in-radius 50 [distance myself] 
    ask entrance [set entrance? true]
    if show_nodes? [ask vertices [set hidden? false]]
    if show_entrances? [ask entrance [set hidden? false set shape "star" set size 0.5]]]

add-people

  set got_to_shop 0
  set got_to_FE 0
  set got_to_dentist_D 0
  set got_to_shop_D 0
  set got_to_FE_D 0
  set got_to_dentist_O 0
  set got_to_shop_O 0
  set got_to_FE_O 0
  
ask links [set thickness 0.001 set color orange]

ask patches [set pcolor white]
;  ask patches gis:intersecting dentist-location-dataset
;  [set pcolor yellow]
;  ask patches gis:intersecting shop-location-dataset
;  [set pcolor pink]
;  ask patches gis:intersecting FE-location-dataset
;  [set pcolor green]

;; adding the background place data ;;

;  foreach gis:feature-list-of sheffield-east-dataset
;  [
;    show gis:property-value ? "CODE"
;    gis:set-drawing-color scale-color white (gis:property-value ? "income") 0 0
;    gis:FILL ? 1.0
;    
;    ask patches [
;      if gis:intersects? ? self[
;        set income gis:property-value ? "income"
;        set code gis:property-value ? "CODE"
;      ]
;    ]
;  ]
;
;
;foreach gis:feature-list-of sheffield-east-dataset
;  [
;    show gis:property-value ? "CODE"
;    gis:set-drawing-color scale-color white (gis:property-value ? "crime") 0 0
;    gis:FILL ? 1.0
;    
;    ask patches [
;      if gis:intersects? ? self[
;        set crime gis:property-value ? "crime"
;        set code gis:property-value ? "CODE"
;      ]
;    ]
;  ]
;
;
;foreach gis:feature-list-of sheffield-east-dataset
;  [
;    show gis:property-value ? "CODE"
;    gis:set-drawing-color scale-color white (gis:property-value ? "hprice") 0 0
;    gis:FILL ? 1.0
;    
;    ask patches [
;      if gis:intersects? ? self[
;        set hprice gis:property-value ? "hprice"
;        set code gis:property-value ? "CODE"
;      ]
;    ]
;  ]
;
;
;foreach gis:feature-list-of sheffield-east-dataset
;  [
;    show gis:property-value ? "CODE"
;    gis:set-drawing-color scale-color white (gis:property-value ? "years_lost") 0 0 ; 500 0
;    gis:FILL ? 1.0
;    
;    ask patches [
;      if gis:intersects? ? self[
;        set years_lost gis:property-value ? "years_lost"
;        set code gis:property-value ? "CODE"
;      ]
;    ]
;  ]

gis:set-drawing-color grey    gis:draw building-dataset 1 
gis:set-drawing-color [  0   0 255]    gis:draw road-dataset 1

ask patch -7 1 [
  set pcolor yellow
]
ask patch -7 0 [
  set pcolor pink
]
ask patch -4 -5 [
  set pcolor pink
]
ask patch 0 -6 [
  set pcolor pink
]
ask patch 3 -7 [
  set pcolor green
]
ask patch 7 -12 [
  set pcolor pink
]
ask patch 7 -5 [
  set pcolor pink
]
ask patch 11 -5 [
  set pcolor pink
]
ask patch 10 14 [
  set pcolor green
]
ask patch 7 12[
  set pcolor pink
]
;import-drawing "U:\\ManWin\\My Documents\\shef_background.jpg"

;; filming the simulation ;;

; let path-m user-new-file
; if not is-string? path-m [stop]
; movie-start "test4.mov"
; movie-set-frame-rate 1
; movie-grab-view
; ;movie-grab-interface
; repeat 200 [
;   move3
;   movie-grab-view
; ]
; movie-close

end  
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1045
866
16
16
25.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

SWITCH
14
64
145
97
show_nodes?
show_nodes?
1
1
-1000

SWITCH
14
105
166
138
show_entrances?
show_entrances?
0
1
-1000

SWITCH
15
146
138
179
show_path?
show_path?
1
1
-1000

BUTTON
13
17
76
50
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
7
189
184
222
prob-of-visiting-dentist
prob-of-visiting-dentist
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
8
235
180
268
prob-of-visiting-shops
prob-of-visiting-shops
0
1
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
8
280
180
313
prob-of-visiting-FE
prob-of-visiting-FE
0
1
1
0.1
1
NIL
HORIZONTAL

MONITOR
1085
46
1195
91
NIL
got_to_dentist_D
17
1
11

MONITOR
1203
46
1307
91
NIL
got_to_shop_D
17
1
11

MONITOR
1313
46
1399
91
NIL
got_to_FE_D
17
1
11

MONITOR
1084
101
1195
146
NIL
got_to_dentist_O
17
1
11

MONITOR
1204
102
1304
147
NIL
got_to_shop_O
17
1
11

MONITOR
1313
102
1400
147
NIL
got_to_FE_O
17
1
11

BUTTON
81
18
150
51
NIL
move3
T
1
T
OBSERVER
NIL
M
NIL
NIL
1

PLOT
10
328
204
508
Tooth decay
Time
Tooth decay
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Tooth decay" 1.0 0 -16777216 true "" "plot sum [numdu98] of people"

MONITOR
146
512
203
557
NIL
ticks
17
1
11

SLIDER
1086
186
1258
219
influence-of-dentist
influence-of-dentist
0
0.1
0
0.1
1
NIL
HORIZONTAL

SLIDER
1086
226
1258
259
influence-of-shops
influence-of-shops
0
0.1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
1086
264
1258
297
influence-of-FE
influence-of-FE
0
0.1
0
0.1
1
NIL
HORIZONTAL

MONITOR
8
512
140
557
NIL
sum [numdu98] of people
2
1
11

BUTTON
65
646
136
679
Profiler
setup                  ; sets up the model\nprofiler:start         ; starts profiling\nrepeat 100 [move3]      ; run the command to be measured\nProfiler:stop          ; stop profiling\nprint profiler:report  ; view the results\nprofiler:reset         ; clear the data
NIL
1
T
OBSERVER
NIL
P
NIL
NIL
1

SLIDER
21
696
193
729
node-precision
node-precision
1
6
3
1
1
NIL
HORIZONTAL

SLIDER
1086
304
1258
337
influence-of-income
influence-of-income
0
1
0
0.5
1
NIL
HORIZONTAL

TEXTBOX
1085
21
1444
63
These monitors help verify the movement procedure is working correctly
11
0.0
1

MONITOR
1084
350
1353
395
NIL
100 - (sum [numdu98] of people / 8524 * 100)
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
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>move3</go>
    <final>reset-ticks</final>
    <exitCondition>ticks = 500</exitCondition>
    <metric>sum [numdu98] of people</metric>
    <enumeratedValueSet variable="influence-of-FE">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-of-shops">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-of-visiting-shops">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_path?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_entrances?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_nodes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-of-dentist">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-of-visiting-FE">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-of-visiting-dentist">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="movement procedure tests" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>move3</go>
    <timeLimit steps="350"/>
    <exitCondition>(ticks = 350)</exitCondition>
    <metric>got_to_dentist_D</metric>
    <metric>got_to_dentist_O</metric>
    <metric>got_to_shop_D</metric>
    <metric>got_to_shop_O</metric>
    <metric>got_to_FE_D</metric>
    <metric>got_to_FE_O</metric>
  </experiment>
  <experiment name="Theory code testing - domain 3, pathway 1" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>move3</go>
    <timeLimit steps="300"/>
    <exitCondition>sum [numdu98] of people &gt; 218</exitCondition>
    <metric>sum [numdu98] of people with [nssec &gt; 4 and inc_est &lt;= 491.8]</metric>
    <metric>sum [numdu98] of people with [nssec &lt;= 4 and inc_est &lt;= 491.8]</metric>
  </experiment>
  <experiment name="location_test(w/out location)" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>move3</go>
    <timeLimit steps="500"/>
    <metric>sum [numdu98] of people</metric>
    <enumeratedValueSet variable="influence-of-dentist">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_entrances?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_path?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="node-precision">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_nodes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-of-income">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-of-FE">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-of-shops">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="location_test(with location)" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>move3</go>
    <timeLimit steps="500"/>
    <metric>sum [numdu98] of people</metric>
    <enumeratedValueSet variable="influence-of-dentist">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_entrances?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_path?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="node-precision">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show_nodes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-of-income">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-of-FE">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-of-shops">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sim" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>move3</go>
    <timeLimit steps="704"/>
    <metric>sum [numdu98] of people</metric>
  </experiment>
  <experiment name="sim2" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>move3</go>
    <timeLimit steps="730"/>
    <metric>sum [numdu98] of people</metric>
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
