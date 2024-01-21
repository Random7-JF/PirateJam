extends Node
#################################
## Inter-object communications ##
#################################

## Weed signals
signal weed_spawned
signal weed_grew
signal weed_spread
signal weed_killed

## Crop signals
signal crop_planted(type)
signal crop_grew(type)
signal crop_harvested(type)
