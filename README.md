
# astar_dart


Features
A* pathfinding algorithm implementation.

Support for different types of movement or grids (e.g., Hex astar).

Handling of random movement and variable pathfinding.

Functionality for searching for neighbors and nearby goals.


 

## Packages Benchmarked



## Benchmark Results

                🏎️ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 💨

The benchmark was run, and the following average execution times were recorded:
grid 32x32 with 60 barriers

| Implementation / Heuristic | Diagonal Movement | Average Run Time (us) | Notes               |
| :------------------------- | :---------------- | :-------------------- | :------------------ |
| - Manhattan                | no                | 730.03                |                     |
| - Hex                      | Possible          | 1233.96               |                     |
| - Euclidean                | Possible          | 1753.23               |                     |


