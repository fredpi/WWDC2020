
import Foundation

struct Rasterizer {
    // MARK: - Subtypes
    private struct Raster: Hashable {
        let x: Int
        let y: Int
    }

    // MARK: - Properties
    private var rasterForPoint: [Point: Raster] = [:]
    private var pointsForRaster: [Raster: [Point]] = [:]
    private let rasterCount: Int
    private var neighborsForRaster: [Raster: [Raster]] = [:]

    // MARK: Cache
    private static var neighborsForRasterForRasterCount: [Int: [Raster: [Raster]]] = [:]

    // MARK: - Initializers
    init(points: [Point], rasterCount: Int) {
        self.rasterCount = rasterCount
        neighborsForRaster = computeNeighborsForRaster()

        // Fill raster for point data
        let rasterCountAsDouble: Double = Double(rasterCount)
        let rasterCountMinusOne: Int = rasterCount - 1
        points.forEach {
            rasterForPoint[$0] = Raster(
                x: min(rasterCountMinusOne, max(0, Int($0.center.x * rasterCountAsDouble))), // Int(double) floors the double
                y: min(rasterCountMinusOne, max(0, Int($0.center.y * rasterCountAsDouble)))
            )
        }

        // Fill point for raster data
        for x in 0..<rasterCount {
            for y in 0..<rasterCount {
                pointsForRaster[Raster(x: x, y: y)] = []
                pointsForRaster.reserveCapacity(5)
            }
        }

        rasterForPoint.forEach { point, raster in
            pointsForRaster[raster]!.append(point)
        }
    }

    // MARK: - Methods
    func getNeighbors(for point: Point) -> [Point] {
        guard let raster = rasterForPoint[point] else { return [] }

        // Don' using flatMap & filter here for performance reasons
        var neighborPoints = [Point]()
        for neighbor in neighborsForRaster[raster]! {
            for neighborPoint in pointsForRaster[neighbor]! {
                if neighborPoint != point {
                    neighborPoints.append(neighborPoint)
                }
            }
        }

        return neighborPoints
    }

    // MARK: Helpers
    private func computeNeighborsForRaster() -> [Raster: [Raster]] {
        if let neighborsForRaster = Rasterizer.neighborsForRasterForRasterCount[rasterCount] {
            return neighborsForRaster
        } else {
            // Compute
            var neighborsForRaster = [Raster: [Raster]]()
            for x in 0..<rasterCount {
                for y in 0..<rasterCount {
                    var neighbors = [Raster]()
                    neighbors.reserveCapacity(8) // 3^2 - 1
                    for neighborX in max(0, x-1)...min(x+1, rasterCount-1) {
                        for neighborY in max(0, y-1)...min(y+1, rasterCount-1) {
                            neighbors.append(Raster(x: neighborX, y: neighborY))
                        }
                    }

                    neighborsForRaster[Raster(x: x, y: y)] = neighbors
                }
            }

            // Cache
            Rasterizer.neighborsForRasterForRasterCount[rasterCount] = neighborsForRaster

            // Return
            return neighborsForRaster
        }
    }
}
