func weightSymbol(for kg: Double) -> String {
    switch kg {
    case 0..<3000:
        return "figure.strengthtraining.traditional"
    case 3000..<5000:
        return "bolt.fill"
    case 5000..<10000:
        return "car.fill"
    case 10000..<20000:
        return "tortoise.fill"
    case 20000..<40000:
        return "truck.box.fill"
    case 40000..<50000:
        return "tram.fill"
    case 50000..<80000:
        return "airplane"
    case 80000..<120000:
        return "flame.fill"
    case 120000..<200000:
        return "mountain.2.fill"
    default:
        return "star.circle.fill"
    }
}

func weightTierName(for kg: Double) -> String {
    switch kg {
    case 0..<3000:
        return "Warmup"
    case 3000..<5000:
        return "Charged"
    case 5000..<10000:
        return "Car Level"
    case 10000..<20000:
        return "Heavyweight"
    case 20000..<40000:
        return "Truck Level"
    case 40000..<50000:
        return "Train Level"
    case 50000..<80000:
        return "Airborne"
    case 80000..<120000:
        return "On Fire"
    case 120000..<200000:
        return "Mountain Level"
    default:
        return "Legendary"
    }
}
