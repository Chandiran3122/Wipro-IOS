import SwiftUI
import Combine

@MainActor
final class DeliveryStore: ObservableObject {
    @Published var partner: DeliveryPartner
    @Published var activeOrder: DeliveryOrder? = nil
    @Published var incomingOrder: DeliveryOrder? = nil
    @Published var incomingOrderRemainingSeconds: Int = 45
    @Published var completedTrips: [CompletedTripRecord] = []
    @Published var incentiveTargets: [IncentiveTarget] = []
    @Published var walletTransactions: [WalletTransaction] = []
    @Published var showCelebrationModal: Bool = false
    @Published var lastDeliveredOrder: DeliveryOrder? = nil
    @Published var showSOSSheet: Bool = false
    @Published var showSupportSheet: Bool = false
    @Published var isSimulatingGpsMove: Bool = false
    
    private var countdownTimer: AnyCancellable?
    
    init() {
        self.partner = DeliveryPartner(
            id: "swiggy-partner-101",
            name: "Rajesh Kumar",
            phone: "+91 98765 43210",
            partnerId: "SW-BLR-84920",
            vehicleNumber: "KA-03-ET-7842",
            vehicleType: "Electric Scooter",
            rating: 4.92,
            totalTripsToday: 7,
            todayEarnings: 820.0,
            weeklyEarnings: 6480.0,
            walletBalance: 2450.0,
            acceptanceRate: 96.0,
            isOnline: true,
            dutyStartTime: Date().addingTimeInterval(-14400), // 4 hours ago
            currentBatteryPercentage: 84,
            todaySwiggyCommission: 110.0,
            weeklySwiggyCommission: 840.0,
            codCashInHand: 580.0,
            bankAccountMasked: "HDFC Bank (A/C: ****4921)",
            upiId: "rajesh.swiggy@okhdfcbank"
        )
        
        self.incentiveTargets = [
            IncentiveTarget(
                id: "inc-1",
                title: "Dinner Peak Bonus",
                description: "Complete 10 deliveries between 7 PM - 11 PM",
                targetOrders: 10,
                bonusAmount: 300.0,
                completedOrders: 7,
                deadline: "Tonight, 11:00 PM",
                isClaimed: false,
                tier: "Peak Rush",
                criteria: ["Min 90% Acceptance", "Dinner Surge Active"]
            ),
            IncentiveTarget(
                id: "inc-2",
                title: "Rain Surge Superstars",
                description: "Complete 5 rain rush orders with 100% acceptance",
                targetOrders: 5,
                bonusAmount: 180.0,
                completedOrders: 5,
                deadline: "Today, 11:59 PM",
                isClaimed: false,
                tier: "Monsoon",
                criteria: ["Target Reached! Ready to Claim", "Rain Zone Active"]
            ),
            IncentiveTarget(
                id: "inc-3",
                title: "Zero Rejection Bonus",
                description: "Accept and complete 10 consecutive orders without cancellations",
                targetOrders: 10,
                bonusAmount: 150.0,
                completedOrders: 10,
                deadline: "Today",
                isClaimed: true,
                tier: "Quality Tier",
                criteria: ["Claimed to Wallet", "100% Acceptance Maintained"]
            ),
            IncentiveTarget(
                id: "inc-4",
                title: "Weekly Mega Milestone",
                description: "Complete 60 deliveries this week for mega jackpot payout",
                targetOrders: 60,
                bonusAmount: 2200.0,
                completedOrders: 44,
                deadline: "Sunday midnight",
                isClaimed: false,
                tier: "Weekly Marathon",
                criteria: ["44/60 Completed", "Payout credited directly to bank"]
            )
        ]
        
        self.completedTrips = [
            CompletedTripRecord(
                id: "tr-1",
                orderNumber: "#SW-9921",
                restaurantName: "Meghana Foods",
                customerArea: "Indiranagar 100ft Road",
                timestamp: Date().addingTimeInterval(-3600),
                earnings: 95.0,
                distanceKm: 4.2,
                tip: 30.0,
                swiggyCommission: 15.0,
                grossEarnings: 110.0
            ),
            CompletedTripRecord(
                id: "tr-2",
                orderNumber: "#SW-9915",
                restaurantName: "Truffles",
                customerArea: "Koramangala 5th Block",
                timestamp: Date().addingTimeInterval(-7200),
                earnings: 75.0,
                distanceKm: 3.1,
                tip: 20.0,
                swiggyCommission: 12.0,
                grossEarnings: 87.0
            ),
            CompletedTripRecord(
                id: "tr-3",
                orderNumber: "#SW-9908",
                restaurantName: "Corner House Ice Cream",
                customerArea: "Domlur BDA Layout",
                timestamp: Date().addingTimeInterval(-10800),
                earnings: 60.0,
                distanceKm: 2.4,
                tip: 10.0,
                swiggyCommission: 10.0,
                grossEarnings: 70.0
            )
        ]
        
        self.walletTransactions = [
            WalletTransaction(
                id: "tx-1",
                title: "Delivery Payout (#SW-9921)",
                orderNumber: "#SW-9921",
                timestamp: Date().addingTimeInterval(-3600),
                amount: 95.0,
                isCredit: true,
                type: .tripPayout,
                note: "Gross: ₹110.00 • Swiggy Comm: -₹15.00 • Tip: ₹30.00"
            ),
            WalletTransaction(
                id: "tx-2",
                title: "Swiggy Platform Fee Taken",
                orderNumber: "#SW-9921",
                timestamp: Date().addingTimeInterval(-3600),
                amount: 15.0,
                isCredit: false,
                type: .swiggyCommission,
                note: "Platform technology & accidental insurance deduction"
            ),
            WalletTransaction(
                id: "tx-3",
                title: "Delivery Payout (#SW-9915)",
                orderNumber: "#SW-9915",
                timestamp: Date().addingTimeInterval(-7200),
                amount: 75.0,
                isCredit: true,
                type: .tripPayout,
                note: "Gross: ₹87.00 • Swiggy Comm: -₹12.00 • Tip: ₹20.00"
            ),
            WalletTransaction(
                id: "tx-4",
                title: "Incentive: Zero Rejection Bonus",
                orderNumber: nil,
                timestamp: Date().addingTimeInterval(-9000),
                amount: 150.0,
                isCredit: true,
                type: .incentiveBonus,
                note: "Quality tier bonus credited to wallet"
            ),
            WalletTransaction(
                id: "tx-5",
                title: "Instant Cashout to Bank",
                orderNumber: nil,
                timestamp: Date().addingTimeInterval(-18000),
                amount: 1000.0,
                isCredit: false,
                type: .bankWithdrawal,
                note: "IMPS transfer to HDFC Bank (****4921) successful"
            )
        ]
        
        // Start with an interesting pending order or offer after a small delay
        prepareInitialSampleOrder()
    }
    
    func toggleDuty() {
        partner.isOnline.toggle()
        if partner.isOnline {
            partner.dutyStartTime = Date()
            HapticManager.playNotification(type: .success)
            // Trigger an order simulation after 2 seconds if idle
            if activeOrder == nil && incomingOrder == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.simulateIncomingOrder()
                }
            }
        } else {
            partner.dutyStartTime = nil
            incomingOrder = nil
            countdownTimer?.cancel()
            HapticManager.playNotification(type: .warning)
        }
    }
    
    func prepareInitialSampleOrder() {
        let sample = generateMockOrder()
        self.incomingOrder = sample
        startIncomingTimer()
    }
    
    func simulateIncomingOrder() {
        guard partner.isOnline, activeOrder == nil else { return }
        incomingOrder = generateMockOrder()
        startIncomingTimer()
        HapticManager.playNotification(type: .warning)
    }
    
    private func startIncomingTimer() {
        incomingOrderRemainingSeconds = 45
        countdownTimer?.cancel()
        countdownTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.incomingOrderRemainingSeconds > 0 {
                    self.incomingOrderRemainingSeconds -= 1
                } else {
                    self.rejectIncomingOrder(reason: "Timed out")
                }
            }
    }
    
    func acceptIncomingOrder() {
        guard var order = incomingOrder else { return }
        countdownTimer?.cancel()
        order.status = .navigatingToRestaurant
        self.activeOrder = order
        self.incomingOrder = nil
        HapticManager.playNotification(type: .success)
    }
    
    func rejectIncomingOrder(reason: String = "Rejected by partner") {
        countdownTimer?.cancel()
        incomingOrder = nil
        HapticManager.playNotification(type: .error)
    }
    
    func markArrivedAtRestaurant() {
        guard var order = activeOrder else { return }
        order.status = .atRestaurant
        activeOrder = order
        HapticManager.playImpact(style: .heavy)
    }
    
    func toggleItemVerification(itemId: String) {
        guard var order = activeOrder else { return }
        if let idx = order.items.firstIndex(where: { $0.id == itemId }) {
            order.items[idx].isVerified.toggle()
            activeOrder = order
            HapticManager.playImpact(style: .light)
        }
    }
    
    func verifyAllItems() {
        guard var order = activeOrder else { return }
        for i in 0..<order.items.count {
            order.items[i].isVerified = true
        }
        activeOrder = order
        HapticManager.playImpact(style: .medium)
    }
    
    func confirmOrderPickedUp() {
        guard var order = activeOrder else { return }
        order.status = .outForDelivery
        activeOrder = order
        HapticManager.playNotification(type: .success)
    }
    
    func markArrivedAtCustomer() {
        guard var order = activeOrder else { return }
        order.status = .atCustomerLocation
        activeOrder = order
        HapticManager.playImpact(style: .heavy)
    }
    
    func completeDelivery(enteredOtp: String) -> Bool {
        guard var order = activeOrder else { return false }
        
        // Check OTP (allow matching or master 1234 for testing convenience)
        let isValidOtp = (enteredOtp == order.otpCode) || (enteredOtp == "1234")
        guard isValidOtp else {
            HapticManager.playNotification(type: .error)
            return false
        }
        
        order.status = .delivered
        let tripEarnings = order.estimatedEarnings
        let tripCommission = order.swiggyCommission
        
        // Update partner stats
        partner.todayEarnings += tripEarnings
        partner.weeklyEarnings += tripEarnings
        partner.walletBalance += tripEarnings
        partner.totalTripsToday += 1
        partner.todaySwiggyCommission += tripCommission
        partner.weeklySwiggyCommission += tripCommission
        
        if order.paymentMode == .cashOnDelivery {
            partner.codCashInHand += order.codAmount
        }
        
        // Progress active incentive targets
        for idx in 0..<incentiveTargets.count {
            if !incentiveTargets[idx].isCompleted {
                incentiveTargets[idx].completedOrders += 1
            }
        }
        
        // Record trip
        let trip = CompletedTripRecord(
            id: UUID().uuidString,
            orderNumber: order.orderNumber,
            restaurantName: order.restaurantName,
            customerArea: order.customerAddress.components(separatedBy: ",").first ?? "Bengaluru",
            timestamp: Date(),
            earnings: tripEarnings,
            distanceKm: order.distanceKm,
            tip: order.tip,
            swiggyCommission: tripCommission,
            grossEarnings: order.grossEarnings
        )
        completedTrips.insert(trip, at: 0)
        
        // Wallet Transactions
        let tripTx = WalletTransaction(
            id: UUID().uuidString,
            title: "Delivery Payout (\(order.orderNumber))",
            orderNumber: order.orderNumber,
            timestamp: Date(),
            amount: tripEarnings,
            isCredit: true,
            type: .tripPayout,
            note: "Gross: ₹\(Int(order.grossEarnings)) • Swiggy Fee: -₹\(Int(tripCommission)) • Tip: ₹\(Int(order.tip))"
        )
        let commTx = WalletTransaction(
            id: UUID().uuidString,
            title: "Swiggy Commission (Taken)",
            orderNumber: order.orderNumber,
            timestamp: Date(),
            amount: tripCommission,
            isCredit: false,
            type: .swiggyCommission,
            note: "12% platform fee on base & surge for \(order.orderNumber)"
        )
        walletTransactions.insert(tripTx, at: 0)
        walletTransactions.insert(commTx, at: 1)
        
        self.lastDeliveredOrder = order
        self.activeOrder = nil
        self.showCelebrationModal = true
        HapticManager.playNotification(type: .success)
        return true
    }
    
    func claimIncentive(targetId: String) {
        guard let index = incentiveTargets.firstIndex(where: { $0.id == targetId && $0.isCompleted && !$0.isClaimed }) else { return }
        
        incentiveTargets[index].isClaimed = true
        let bonus = incentiveTargets[index].bonusAmount
        
        partner.walletBalance += bonus
        partner.todayEarnings += bonus
        
        let tx = WalletTransaction(
            id: UUID().uuidString,
            title: "Bonus Claimed: \(incentiveTargets[index].title)",
            orderNumber: nil,
            timestamp: Date(),
            amount: bonus,
            isCredit: true,
            type: .incentiveBonus,
            note: "\(incentiveTargets[index].targetOrders) orders completed target bonus"
        )
        walletTransactions.insert(tx, at: 0)
        HapticManager.playNotification(type: .success)
    }
    
    func withdrawEarnings(amount: Double) {
        guard amount > 0, amount <= partner.walletBalance else { return }
        
        partner.walletBalance -= amount
        let tx = WalletTransaction(
            id: UUID().uuidString,
            title: "Instant Cashout to Bank",
            orderNumber: nil,
            timestamp: Date(),
            amount: amount,
            isCredit: false,
            type: .bankWithdrawal,
            note: "Instant IMPS payout to \(partner.bankAccountMasked)"
        )
        walletTransactions.insert(tx, at: 0)
        HapticManager.playNotification(type: .success)
    }
    
    func settleCodCash() {
        guard partner.codCashInHand > 0 else { return }
        let amount = partner.codCashInHand
        partner.codCashInHand = 0
        
        let tx = WalletTransaction(
            id: UUID().uuidString,
            title: "COD Cash Settle with Swiggy",
            orderNumber: nil,
            timestamp: Date(),
            amount: amount,
            isCredit: false,
            type: .codSettlement,
            note: "Customer cash deposit reconciled via UPI"
        )
        walletTransactions.insert(tx, at: 0)
        HapticManager.playNotification(type: .success)
    }
    
    private func generateMockOrder() -> DeliveryOrder {
        let options: [(restName: String, restAddr: String, custName: String, custAddr: String, items: [OrderItem], base: Double, surge: Double, tip: Double, isCod: Bool, cod: Double, dist: Double)] = [
            (
                restName: "Meghana Foods - Biryani & More",
                restAddr: "54, 100ft Rd, HAL 2nd Stage, Indiranagar",
                custName: "Aditi Sharma",
                custAddr: "Tower B - 604, Godrej Platinum, Hebbal",
                items: [
                    OrderItem(name: "Special Chicken Biryani (Family Pack)", quantity: 1, isVeg: false, specialInstructions: "Extra raita and salan"),
                    OrderItem(name: "Paneer 65 Crispy Dry", quantity: 1, isVeg: true, specialInstructions: "Spicy")
                ],
                base: 65.0, surge: 25.0, tip: 30.0, isCod: false, cod: 0.0, dist: 4.8
            ),
            (
                restName: "Empire Restaurant",
                restAddr: "Church Street, Brigade Road Junction",
                custName: "Vikram Malhotra",
                custAddr: "Flat 201, Sobha City, Thanisandra Main Rd",
                items: [
                    OrderItem(name: "Empire Special Ghee Rice", quantity: 2, isVeg: true),
                    OrderItem(name: "Chicken Kebab (Full)", quantity: 1, isVeg: false),
                    OrderItem(name: "Coin Parotta (Pack of 4)", quantity: 2, isVeg: true)
                ],
                base: 55.0, surge: 15.0, tip: 20.0, isCod: true, cod: 580.0, dist: 3.9
            ),
            (
                restName: "Truffles Gourmet Burgers",
                restAddr: "28, 4th Block, 80 Feet Road, Koramangala",
                custName: "Sneha Reddy",
                custAddr: "No. 12, 1st Cross, Green Glen Layout, Bellandur",
                items: [
                    OrderItem(name: "All American Cheese Burger", quantity: 2, isVeg: false, specialInstructions: "No pickles"),
                    OrderItem(name: "Crispy Peri-Peri Fries", quantity: 1, isVeg: true),
                    OrderItem(name: "Ferrero Rocher Thick Shake", quantity: 1, isVeg: true)
                ],
                base: 70.0, surge: 30.0, tip: 40.0, isCod: false, cod: 0.0, dist: 5.2
            ),
            (
                restName: "Rameshwaram Cafe",
                restAddr: "12th Main Rd, HAL 2nd Stage, Indiranagar",
                custName: "Karthik Iyer",
                custAddr: "B-302, Prestige Ferns, Bellandur",
                items: [
                    OrderItem(name: "Ghee Podi Idli (2 Pcs)", quantity: 2, isVeg: true),
                    OrderItem(name: "Open Butter Masala Dosa", quantity: 1, isVeg: true),
                    OrderItem(name: "Filter Coffee Flask", quantity: 1, isVeg: true)
                ],
                base: 45.0, surge: 10.0, tip: 25.0, isCod: false, cod: 0.0, dist: 3.2
            )
        ]
        
        let choice = options.randomElement()!
        // Commission taken by Swiggy: 12% on delivery fee (base + surge). Tips are 100% kept by rider (0% commission).
        let deliveryFee = choice.base + choice.surge
        let commission = Double(max(10, Int(deliveryFee * 0.12)))
        let netEarnings = (deliveryFee - commission) + choice.tip
        
        let random4Digits = String(format: "%04d", Int.random(in: 1000...9999))
        let orderNum = "#SW-\(Int.random(in: 7000...9999))"
        
        return DeliveryOrder(
            id: UUID().uuidString,
            orderNumber: orderNum,
            restaurantName: choice.restName,
            restaurantAddress: choice.restAddr,
            restaurantPhone: "+91 80 4123 9988",
            restaurantLatitude: 12.9716,
            restaurantLongitude: 77.5946,
            customerName: choice.custName,
            customerAddress: choice.custAddr,
            customerPhone: "+91 99001 54321",
            customerLatitude: 12.9352,
            customerLongitude: 77.6245,
            customerInstructions: "Please don't ring the bell, baby is sleeping. Leave with security if gate is locked.",
            items: choice.items,
            estimatedEarnings: netEarnings,
            basePay: choice.base,
            surgePay: choice.surge,
            tip: choice.tip,
            swiggyCommission: commission,
            paymentMode: choice.isCod ? .cashOnDelivery : .prepaid,
            codAmount: choice.cod,
            distanceKm: choice.dist,
            estimatedMinutes: Int(choice.dist * 4 + 10),
            createdAt: Date(),
            status: .pendingAcceptance,
            otpCode: random4Digits
        )
    }
}
