import Foundation
import CoreLocation

enum DeliveryStatus: String, CaseIterable, Codable {
    case pendingAcceptance = "New Request"
    case navigatingToRestaurant = "Navigating to Restaurant"
    case atRestaurant = "At Restaurant"
    case outForDelivery = "Out for Delivery"
    case atCustomerLocation = "At Delivery Location"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    
    var stepIndex: Int {
        switch self {
        case .pendingAcceptance: return 0
        case .navigatingToRestaurant: return 1
        case .atRestaurant: return 2
        case .outForDelivery: return 3
        case .atCustomerLocation: return 4
        case .delivered: return 5
        case .cancelled: return -1
        }
    }
}

enum PaymentMode: String, Codable {
    case prepaid = "Prepaid (Online)"
    case cashOnDelivery = "Cash on Delivery"
}

struct OrderItem: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    let name: String
    let quantity: Int
    let isVeg: Bool
    var specialInstructions: String? = nil
    var isVerified: Bool = false
}

struct DeliveryOrder: Identifiable, Codable, Equatable {
    let id: String
    let orderNumber: String
    let restaurantName: String
    let restaurantAddress: String
    let restaurantPhone: String
    let restaurantLatitude: Double
    let restaurantLongitude: Double
    
    let customerName: String
    let customerAddress: String
    let customerPhone: String
    let customerLatitude: Double
    let customerLongitude: Double
    var customerInstructions: String?
    
    var items: [OrderItem]
    let estimatedEarnings: Double // Net earnings credited to partner wallet
    let basePay: Double
    let surgePay: Double
    let tip: Double // 100% tip goes to rider, Swiggy takes 0% commission on tips
    let swiggyCommission: Double // Platform service commission taken by Swiggy
    let paymentMode: PaymentMode
    let codAmount: Double
    let distanceKm: Double
    let estimatedMinutes: Int
    let createdAt: Date
    var status: DeliveryStatus
    let otpCode: String // 4-digit code customer gives to rider
    
    var grossEarnings: Double {
        basePay + surgePay + tip
    }
    
    var netEarnings: Double {
        estimatedEarnings
    }
    
    var restaurantCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: restaurantLatitude, longitude: restaurantLongitude)
    }
    
    var customerCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: customerLatitude, longitude: customerLongitude)
    }
}

struct IncentiveTarget: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let targetOrders: Int
    let bonusAmount: Double
    var completedOrders: Int
    let deadline: String
    var isClaimed: Bool = false
    var tier: String = "Peak Bonus"
    var criteria: [String] = []
    
    var isCompleted: Bool {
        completedOrders >= targetOrders
    }
    
    var progress: Double {
        min(1.0, Double(completedOrders) / Double(targetOrders))
    }
}

struct CompletedTripRecord: Identifiable, Codable {
    let id: String
    let orderNumber: String
    let restaurantName: String
    let customerArea: String
    let timestamp: Date
    let earnings: Double // Net earnings
    let distanceKm: Double
    let tip: Double
    var swiggyCommission: Double = 12.0
    var grossEarnings: Double = 107.0
}

enum WalletTransactionType: String, Codable, CaseIterable {
    case tripPayout = "Delivery Payout"
    case swiggyCommission = "Swiggy Commission (Taken)"
    case incentiveBonus = "Incentive Bonus Credited"
    case bankWithdrawal = "Instant Cashout to Bank"
    case codSettlement = "COD Cash Settlement"
}

struct WalletTransaction: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    let title: String
    let orderNumber: String?
    let timestamp: Date
    let amount: Double
    let isCredit: Bool
    let type: WalletTransactionType
    let note: String?
}

struct DeliveryPartner: Codable {
    var id: String
    var name: String
    var phone: String
    var partnerId: String
    var vehicleNumber: String
    var vehicleType: String
    var rating: Double
    var totalTripsToday: Int
    var todayEarnings: Double
    var weeklyEarnings: Double
    var walletBalance: Double
    var acceptanceRate: Double
    var isOnline: Bool
    var dutyStartTime: Date?
    var currentBatteryPercentage: Int
    var todaySwiggyCommission: Double = 110.0
    var weeklySwiggyCommission: Double = 840.0
    var codCashInHand: Double = 580.0
    var bankAccountMasked: String = "HDFC Bank (A/C: ****4921)"
    var upiId: String = "rajesh.swiggy@okhdfcbank"
}
