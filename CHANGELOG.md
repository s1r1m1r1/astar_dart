## 5.0.0
  - improve heuristic function
  - fix reconstruct() in findPath
  - using SplayTreeMap instead sort 
  - start point is always return as first element in path

## 4.0.0
  - added findStepsTargets()
  - added reconstructNormalized() to find path for findPath() 
  - added reconstruct() to find path for targets and steps 
  - fix some bug in findTargets()
  - improve example/main.dart
  - for complex search recommend use findStepsTargets() with reconstruct() 

## 3.2.0
  - added findStepsTargets()
  - fix some bug in findTargets()
  - improve example/main.dart

## 3.1.0
  - fixed some bugs findSteps

## 3.0.0
  - new version is really fast ,
  - findPath() 80% performance improvement 
  - findSteps() , findTargets() , more a lot of performance improvement
  - findTarget() all target detected as not movable  , while search them

## 2.4.5
  - chore update dependencies

## 2.4.4
  - added option resetBarrier  to resetNodes()

## 2.4.3
  - added setBarrier() , setPoint() to AstarGrid

## 2.4.2
  - bugfix AStarHex _isNeighbors incorrect check

## 2.4.1
  - added reset() for ANode , clear h ,g , parent value , improve performance 
  - added resetNodes() to reset Grid, improve performance 

## 2.4.0
  - fix degradation on euclidean algorithm 

## 2.3.0
  - extract Array2d as package
  - update hex example 

## 2.2.0
  - remove BarrierPoint 
  - added hex example 

## 2.1.0
  - improve performance 
  - added hex example 

## 2.0.0
   - make it faster 
   - added gridBuilder

## 1.2.0
  - improve example 
  - Array2D added valueBuilder

## 1.1.0
  - separate by  manhattan , euclidean , hex  

## 1.0.0
  added support for hex tiles

